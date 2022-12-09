//
//  SNZGAudio.m
//  SonaSDK
//
//  Created by Insomnia on 2019/12/4.
//

#import "SNZGAudio.h"
#import <ZegoLiveRoom/ZegoLiveRoom.h>
#import <ZegoLiveRoom/zego-api-mediaplayer-oc.h>
#import <ZegoLiveRoom/zego-api-sound-level-oc.h>
#import <ZegoLiveRoom/ZegoLiveRoomApi-AudioIO.h>
#import <ZegoLiveRoom/zego-api-mix-stream-oc.h>
#import <ZegoLiveRoom/ZegoLiveRoomApi-Publisher.h>
#import <ZegoLiveRoom/zego-api-audio-device-oc.h>
#import "SNMacros.h"
#import "NSDictionary+SNProtectedKeyValue.h"
#import "SNLoggerHelper.h"
#import "SNZGAudioPrepProxy.h"
#import "SNZGMediaPlayer.h"
#import <ZegoLiveRoom/zego-api-media-side-info-oc.h>
#import <AVFoundation/AVFoundation.h>
#import "SNZGSeiService.h"
#import "SNSubjectCleaner.h"
#import "SNEventSignpost.h"
#import "SNAudioRetry.h"
#import "SNThreadSafeSet.h"
#import "SNThreadSafeDictionary.h"

static NSString * const SNOutputVolumeKey = @"outputVolume";

#define BitrateMin 64000
#define BitrateMax 128000

@interface SNZGAudio () <ZegoRoomDelegate, ZegoLivePublisherDelegate, ZegoAVEngineDelegate, ZegoMediaPlayerEventWithIndexDelegate, ZegoSoundLevelDelegate, ZegoLiveEventDelegate,ZegoLiveSoundLevelInMixedStreamDelegate, ZegoDeviceEventDelegate, ZegoLivePlayerDelegate, ZegoMediaSideDelegate, SNZGSeiServiceDelegate, ZegoVideoRenderDelegate, ZegoVideoRenderCVPixelBufferDelegate>

@property(nonatomic, strong, readwrite) ZegoLiveRoomApi *zegoApi;
@property(nonatomic, strong, readwrite) ZegoMediaPlayer *zegoMediaPlayer;
@property(nonatomic, strong, readwrite) SNConfigModel *configModel;

@property(nonatomic, assign) BOOL publishing;
/**
 * 是否在sonaRoom。不一定登录了zegoRoom，拉混流的情况下，未登录zego也是true
 */
@property(nonatomic, assign) BOOL entered;
/**
 * 是否登录了zegoRoom
 */
@property(nonatomic, assign, getter=isLoginRoom) BOOL loginRoom;
/**
 * 正在登录房间
 */
@property(nonatomic, assign, getter=isLoginingRoom) BOOL loginingRoom;
@property(nonatomic, copy) NSString *publishingStream;

@property(nonatomic, strong) SNThreadSafeSet *zegoStreamsMSet;
@property(nonatomic, strong) SNThreadSafeSet *pullingStreamsMSet;
@property(nonatomic, strong) SNThreadSafeSet *pullingAccIdMSet;
@property(nonatomic, strong) SNThreadSafeDictionary *zegoStreamMDic;
@property(nonatomic, strong) RACSubject *volumeSubject;
@property(nonatomic, strong) RACSubject *disconnectSubject;
@property(nonatomic, strong) RACSubject *reconnectSubject;
@property(nonatomic, strong) RACSubject *voiceApertureSubject;
@property (nonatomic, strong) RACSubject *publishEventCallback;
@property (nonatomic, strong) RACSubject *videoFirstRenderCallback;

@property (nonatomic, strong) RACSubject *onPublishStreamFail;
@property (nonatomic, strong) RACSubject *onPublishStreamSuccess;
@property (nonatomic, strong) RACSubject *onPullStreamFail;
@property (nonatomic, strong) RACSubject *onPullStreamSuccess;
@property (nonatomic, strong) RACSubject *onKickOutRoom;

@property (nonatomic, strong) RACSubject *onNeedCheckConfig;

@property (atomic, assign, getter=isFirstRender) BOOL firstRender;

@property(nonatomic, strong) ZegoStreamMixer *streamMixer;

@property(nonatomic, strong) NSDate *dateForFrequency;

@property (nonatomic, assign, getter=isCreateSdkFail) BOOL createSdkFail;

@property (nonatomic, strong) SNZGAudioPrepProxy *audioPrepProxy;

@property (nonatomic, assign) CGFloat lastPublishAudioBitrate;

@property (nonatomic, strong) RACSubject *onReceiveMediaSideInfo;

@property (nonatomic, strong) SNZGMediaPlayer *mediaPlayer;

// 最新的包含视频流的流id
@property (nonatomic, copy) NSString *lastVideoStreamId;

@property (nonatomic, strong) SNZGSeiService *seiService;

@property (nonatomic, assign) BOOL hasSetView;

@property (nonatomic, weak) UIView *streamView;

@property (nonatomic, strong) dispatch_queue_t loginQueue;

@property (nonatomic, strong) dispatch_queue_t destroyPlayerQueue;

@property (nonatomic, strong) NSMutableArray *loginObservers;

@property (nonatomic, copy) NSString *pullMode;

@property (atomic, assign, getter=isMuteOutputVolume) BOOL muteOutputVolume;

@property (nonatomic, strong) SNEventSignpost *signpost;

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *pullMap;

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *publishMap;

@property (nonatomic, strong) SNAudioRetry *audioRetry;

@property (nonatomic, assign) SRDeviceMode defaultDeviceMode;

@end

@implementation SNZGAudio

+ (void)load {
    RACSignal *loginOutSignal = [[NSNotificationCenter defaultCenter] rac_addObserverForName:@"ZegoUploadLog" object:nil];
    [[loginOutSignal takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification *notification) {
        [ZegoLiveRoomApi uploadLog];
    }];
}

- (instancetype)initWithConfigModel:(SNConfigModel *)configModel {
    self = [super init];
    if (self) {
        self.configModel = configModel;
        [self setup];
        [self onBeforeInitSDK];
        [self onInitSDK];
        [self onAfterInitSDK];
//        [self mediaSideInfo];
        [self setupVolumeObserver];
    }
    return self;
}

- (void)setupVolumeObserver {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    @weakify(self)
    [[[session rac_valuesAndChangesForKeyPath:SNOutputVolumeKey
                                      options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                                     observer:self] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(RACTuple *tuple) {
        @strongify(self)
        RACTupleUnpack(NSNumber *newValue, NSDictionary *change) = tuple;
        SN_LOG_LOCAL(@"Sona Logan: volume change: %@", change);
        if (!change) {
            return;
        }
        if (!self.zegoApi) {
            SN_LOG_LOCAL(@"Sona Logan: zegoApi not exist");
            return;
        }
        CGFloat newVolume = [newValue floatValue];
        
        if (newVolume <= 0) {
            self.muteOutputVolume = true;
            [self.zegoApi enableSpeaker:false];
            SN_LOG_LOCAL(@"Sona Logan: disableSpeaker");
        }
        if (newVolume > 0 && self.isMuteOutputVolume) {
            self.muteOutputVolume = false;
            [self.zegoApi enableSpeaker:true];
            SN_LOG_LOCAL(@"Sona Logan: enableSpeaker");
        }
    }];
}

- (void)setup {
    self.loginingRoom = false;
    self.firstRender = true;
    self.muteOutputVolume = false;
    self.defaultDeviceMode = (SRDeviceMode)[self.configModel.attMDic snIntegerForKey:@"deviceMode"];
    self.pullMode = self.configModel.productConfig.streamConfig.pullMode;
    self.loginQueue = dispatch_queue_create("com.sona.zg.login", DISPATCH_QUEUE_SERIAL);
    self.destroyPlayerQueue = dispatch_queue_create("com.sona.destroyPlayer", DISPATCH_QUEUE_SERIAL);
    
    self.signpost = [SNEventSignpost new];
    
    self.audioRetry = [[SNAudioRetry alloc] initWithAudio:self];
    
    [self setupCollections];
}

- (void)setupCollections {
    self.zegoStreamsMSet = [SNThreadSafeSet new];
    self.pullingStreamsMSet = [SNThreadSafeSet new];
    self.pullingAccIdMSet = [SNThreadSafeSet new];
    self.zegoStreamMDic = [SNThreadSafeDictionary new];
}

#pragma mark - life cycle

- (void)onBeforeInitSDK {
    
    self.publishing = NO;
    self.createSdkFail = ![ZegoLiveRoomApi setUserID:self.configModel.uid userName:self.configModel.uid];
    if (self.createSdkFail) {
        SN_LOG_LOCAL(@"Init SDK Fail - setUserID:userName, uid:%@", self.configModel.uid);
    }
    [self setDeviceMode:self.defaultDeviceMode];
    [ZegoLiveRoomApi setPublishQualityMonitorCycle:3];
    [ZegoLiveRoomApi setBusinessType:0];
    [ZegoLiveRoomApi setLogSize:10*1024*1024];
    [ZegoLiveRoomApi setConfig:@"av_retry_time=5"];
    BOOL env = [[self.configModel.attMDic valueForKey:@"env"] integerValue] == 0;
    [ZegoLiveRoomApi setUseTestEnv:env];
    [ZegoAVConfig presetConfigOf:ZegoAVConfigPreset_High];
    
    [ZegoLiveRoomApi setPlayQualityMonitorCycle:10*1000];
}

- (void)onInitSDK {
    NSInteger appId = [[self.configModel.attMDic valueForKey:@"appId"] integerValue];
    NSData *sig = [NSData new];
    if ([[self.configModel.attMDic valueForKey:@"sig"] isKindOfClass:[NSData class]]) {
        sig = [self.configModel.attMDic valueForKey:@"sig"];
    }
    self.zegoApi = [[ZegoLiveRoomApi alloc] initWithAppID:(unsigned int) appId appSignature:sig];
    if (!_zegoApi) {
        self.createSdkFail = true;
        SN_LOG_LOCAL(@"Sona Logan: Init SDK Fail - initWithAppID:appSignature, config:%@",self.configModel.attMDic);
    }
    [_zegoApi setDeviceEventDelegate:self];
    [_zegoApi enableAGC:YES];
    [_zegoApi enableAEC:YES];
    
    if ([self.configModel.productConfig.streamConfig.switchSpeaker isEqualToString:@"1"]) {
        [_zegoApi enableAECWhenHeadsetDetected:YES];
    }
    
    [_zegoApi enableNoiseSuppress:YES];
    [_zegoApi enableCamera:false];
    [_zegoApi setFrontCam:NO];
    
    [_zegoApi setRoomDelegate:self];
    [_zegoApi setPublisherDelegate:self];
    [_zegoApi setAVEngineDelegate:self];
    [_zegoApi setLiveEventDelegate:self];
    [_zegoApi setPlayerDelegate:self];
    [_zegoApi setLatencyMode:ZEGOAPI_LATENCY_MODE_NORMAL];
    [ZegoAudioDevice enableAudioCaptureStereo:1];
    [_zegoApi setAudioChannelCount:2];
    // 码率低于64K, 或者高于128K，都认为是异常，客户端做兜底。
    int bitrate = (int)MIN(MAX(self.configModel.productConfig.streamConfig.bitrate, BitrateMin), BitrateMax);
    BOOL bitrateSuccess = [_zegoApi setAudioBitrate:bitrate];
    if (!bitrateSuccess) {
        SN_LOG_LOCAL(@"Zego Set Bitrate Fail");
    }
}

- (void)onAfterInitSDK {
    self.seiService = [[SNZGSeiService alloc] initWithZegoApi:self.zegoApi];
    self.seiService.delegate = self;
    
    [ZegoExternalVideoRender setVideoRenderType:VideoRenderTypeExternalInternalRgb];
    [[ZegoExternalVideoRender sharedInstance] setZegoVideoRenderDelegate:self];
    [ZegoLiveRoomApi setConfig:@"rtmp_adjust_timestamp=true"];
    
    // 提前初始化AME播放器，因为第一次下载 License 会比较久
    [self musicPlayer];
}

- (void)checkAndInitSDK {
    if (!_zegoApi) {
        [self onBeforeInitSDK];
        [self onInitSDK];
        [self onAfterInitSDK];
    }
}

#pragma mark Override

- (RACSignal *)updateConfigModel:(SNConfigModel *)configModel {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        NSString *lastPullMode = self.configModel.productConfig.streamConfig.pullMode;
        self.configModel = configModel;
        // 如果当前是单流，不再更新。
        if (![self.pullMode isEqualToString:SN_STREAM_PULL_MODE_MULTI]) {
            self.pullMode = configModel.productConfig.streamConfig.pullMode;
        }
        if(![configModel.productConfig.streamConfig.pullMode isEqualToString:lastPullMode]) {
            if ([configModel.productConfig.streamConfig.pullMode isEqualToString:SN_STREAM_PULL_MODE_MIXED]) {
                //当前为混流，监听混流的流回调
                self.dateForFrequency = [NSDate date];
                [self.streamMixer setSoundLevelInMixedStreamDelegate:self];
                self.dateForFrequency = [NSDate date];
            }else {
                //当前为单流，监听单流的流回调
                [self.streamMixer setSoundLevelInMixedStreamDelegate:nil];
            }
        }
        [subscriber sendNext:nil];
        [subscriber sendCompleted];
        return nil;
    }];
}


- (RACSignal *)enter {
    return [self enter:false];
}

- (RACSignal *)enter:(BOOL)isForce {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        @strongify(self);
        [self checkAndInitSDK];
        NSString *roomId = [self.configModel.productConfig.streamConfig.streamRoomId snStringForKey:@"ZEGO"];
        SN_LOG_LOCAL(@"Zego enter %@, roomId: %@", self.configModel.productConfig.productCode, roomId);
        
        if (self.isCreateSdkFail) {
            SN_LOG_LOCAL(@"Zego Sdk Init Fail, Config:%@", self.configModel.attMDic);
            self.createSdkFail = false;
        }
        
        if (!isForce && ![self shouldLogin]) {
            self.entered = YES;
            SN_LOG_LOCAL(@"Zego Enter Success(No Login Zego), streamRoomId:%@", roomId);
            [self.streamMixer setSoundLevelInMixedStreamDelegate:self];
            self.dateForFrequency = [NSDate date];
            [subscriber sendNext:@(SNCodeZegoEnterSuccess)];
            [subscriber sendCompleted];
            return nil;
        }
        // 需要登录的场景
        [self.streamMixer setSoundLevelInMixedStreamDelegate:nil];
        [[ZegoSoundLevel sharedInstance] setSoundLevelDelegate:self];
        [[ZegoSoundLevel sharedInstance] setSoundLevelMonitorCycle:500];
        [[ZegoSoundLevel sharedInstance] startSoundLevelMonitor];
        SN_LOG_LOCAL(@"Zego Will Enter(login zego room), streamRoomId:%@", roomId);
        [self asyncLoginRoom:roomId subscriber:subscriber];
        return nil;
    }];
}

- (void)asyncLoginRoom:(NSString *)roomId subscriber:(id<RACSubscriber>)subscriber {
    @weakify(self)
    dispatch_async(self.loginQueue, ^{
        @strongify(self)
        if (!subscriber) {
            return;
        }
        if (self.isLoginRoom) {
            [subscriber sendNext:@(SNCodeZegoEnterSuccess)];
            [subscriber sendCompleted];
            return;
        }
        [self.loginObservers addObject:subscriber];
        if (self.isLoginingRoom) {
            return;
        }
        self.loginingRoom = true;

        NSDictionary *sorakaInfo = @{SRRoomSorakaLogDescKey:@"Zego Enter Duration",
                                     @"streamRoomId":roomId};
        [self.signpost begin:SRRoomSorakaLogAudioLoginDuration spid:roomId ext:sorakaInfo];
        
        BOOL flag = [self.zegoApi loginRoom:roomId role:ZEGO_ANCHOR withCompletionBlock:^(int errorCode, NSArray<ZegoStream *> *streamList) {
            @strongify(self);
            dispatch_async(self.loginQueue, ^{
                @strongify(self)
                [self clearCollectionData];
                if (!errorCode) {
                    
                    [self.signpost end:SRRoomSorakaLogAudioLoginDuration spid:roomId];
                    
                    for (ZegoStream *zgStream in streamList) {
                        if ([zgStream.streamID isEqualToString:self.configModel.productConfig.streamConfig.streamId]) {
                            continue;
                        }
                        [self.zegoStreamsMSet addObject:zgStream.streamID];
                        [self.zegoStreamMDic setValue:zgStream.userID forKey:zgStream.streamID];
                    }
                    
                    [[self switchMicWith:self.configModel.micEnabled] subscribeNext:^(id x) {}];
                    
                    self.entered = YES;
                    self.loginRoom = YES;
                    SN_LOG_LOCAL(@"Zego Enter Success(Login Zego)");
                    [self.loginObservers enumerateObjectsUsingBlock:^(id<RACSubscriber> observer, NSUInteger idx, BOOL * _Nonnull stop) {
                        [observer sendNext:@(SNCodeZegoEnterSuccess)];
                        [observer sendCompleted];
                    }];
                    [self.loginObservers removeAllObjects];
                } else {
                    self.entered = NO;
                    self.loginRoom = NO;
                    SN_LOG_LOCAL(@"Zego Enter Fail");
                    [self.loginObservers enumerateObjectsUsingBlock:^(id<RACSubscriber> observer, NSUInteger idx, BOOL * _Nonnull stop) {
                        [observer sendNext:@(SNCodeZegoEnterFail)];
                        [observer sendCompleted];
                    }];
                    [self.loginObservers removeAllObjects];
                }
                self.loginingRoom = false;
            });
        }];
        if (!flag) {
            self.loginingRoom = false;
            SN_LOG_LOCAL(@"Zego Enter Fail");
            [self.loginObservers enumerateObjectsUsingBlock:^(id<RACSubscriber> observer, NSUInteger idx, BOOL * _Nonnull stop) {
                [observer sendNext:@(SNCodeZegoEnterFail)];
                [observer sendCompleted];
            }];
            [self.loginObservers removeAllObjects];
        }
    });
}

- (BOOL)beenEntered {
    return self.entered;
}

- (RACSignal *)reEnter {
    return [self enter];
}

- (RACSignal *)leave {
    @weakify(self);
    SN_LOG_LOCAL(@"Zego Leave %@, streamRoomId: %@", self.configModel.productConfig.productCode, self.configModel.productConfig.streamConfig.streamRoomId);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        [[self stopPublish] subscribeNext:^(id x) {}];
        [[self stopPullAllId] subscribeNext:^(id x) {}];
        [self destroyPlayer];
        BOOL logout = [self.zegoApi logoutRoom];
        [self.audioPrepProxy closeAudioPreprocess];
        self.entered = false;
        self.zegoApi = nil;
        
        id streamRoomId = self.configModel.productConfig.streamConfig.streamRoomId ? : @"";
        
        if (!self.loginRoom || logout) {
            SN_LOG_LOCAL(@"Zego Leave Success, streamRoomId %@", streamRoomId);
            [subscriber sendNext:@(SNCodeZegoLeaveSuccess)];
        } else {
            SN_LOG_LOCAL(@"Zego Leave Fail(API), streamRoomId %@", streamRoomId);
            [subscriber sendError:[SonaError errWithCode:SNCodeZegoLeaveFail streamId:streamRoomId]];
        }
        self.loginRoom = false;
        [SNSubjectCleaner clear:self];
        [subscriber sendCompleted];
        return nil;
    }];
}

- (RACSignal *)startPublishWithId:(NSString *)stream {
    stream = stream ? : @"";
    @weakify(self);
    return [[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        @strongify(self)
        self.pullMode = SN_STREAM_PULL_MODE_MULTI;
        if (self.publishing) {
            [subscriber sendNext:@(SNCodeZegoPublishStreamSuccess)];
        } else {
            SN_LOG_LOCAL(@"Zego Start Publish, streamId:%@",stream);
            int flag = ZEGO_MIX_STREAM;
            [self ensureLogin:^{
                @strongify(self)
                if ([self.zegoApi startPublishing:stream title:stream flag:flag]) {
                    self.publishing = YES;
                    self.publishingStream = stream;
                    self.lastPublishAudioBitrate = 1;
                    SN_LOG_LOCAL(@"Zego Start Publish Success, streamId: %@", stream);
                    [subscriber sendNext:@(SNCodeZegoPublishStreamSuccess)];
                    [subscriber sendCompleted];
                } else {
                    SN_LOG_LOCAL(@"Zego Start Publish Fail, streamId:%@", stream);
                    [subscriber sendError:[SonaError errWithCode:SNCodeZegoPublishStreamFail]];
                    
                }
            } loginFail:^{
                [subscriber sendError:[SonaError errWithCode:SNCodeZegoEnterFail]];
                [subscriber sendCompleted];
            }];
        }
        return nil;
    }] retry:3];
}

- (RACSignal *)stopPublish {
    @weakify(self);
    return [[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        @strongify(self)
        if (!self.publishing) {
            [subscriber sendNext:@(SNCodeZegoStopPublishSuccess)];
        } else {
            SN_LOG_LOCAL(@"Zego Stop Publish, streamId:%@", self.publishingStream);
            if ([self.zegoApi stopPublishing]) {
                self.publishing = NO;
                SN_LOG_LOCAL(@"Zego Stop Publish Success, streamId:%@",self.publishingStream);
                self.publishingStream = nil;
                [subscriber sendNext:@(SNCodeZegoStopPublishSuccess)];
            } else {
                SN_LOG_LOCAL(@"Zego Stop Publish Fail, streamId:%@", self.publishingStream);
                [subscriber sendError:[SonaError errWithCode:SNCodeZegoStopPublishFail]];
            }
        }
        [subscriber sendCompleted];
        return nil;
    }] retry:3];
}

- (RACSignal *)startPullWithId:(NSString *)stream {
    return [self startPullWithIdArr:@[stream]];
}

- (RACSignal *)startPullWithIdArr:(NSArray <NSString *> *)streamArr {
    @weakify(self);
    return [[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        @strongify(self)
        [self ensureLogin:^{
            @strongify(self)
            SN_LOG_LOCAL(@"Zego Start Pull Mutil, streamIds: %@", streamArr);
            for (NSString *stream in streamArr) {
                if (self.publishing && [stream isEqualToString:self.publishingStream]) {
                    continue;
                }
                
                if ([self.zegoApi startPlayingStream:stream inView:nil]) {
                    [self.signpost begin:SRRoomSorakaLogPullMultiDuration spid:stream ext:@{SRRoomSorakaLogDescKey:@"Zego Pull Mutil Duration"}];
                    [self.zegoApi setPlayVolume:100 ofStream:stream];
                    [self.pullingStreamsMSet addObject:stream];
                } else {
                    SN_LOG_LOCAL(@"Zego Start Pull Mutil Fail, streamId: %@", stream);
                    [subscriber sendError:[SonaError errWithCode:SNCodeZegoStartPullMultiStreamFail]];
                    [subscriber sendCompleted];
                }
            }
            SN_LOG_LOCAL(@"Zego Start Pull Mutil Success, streams: %@", streamArr);
            [subscriber sendNext:@(SNCodeZegoStartPullMultiStreamSuccess)];
            [subscriber sendCompleted];
        } loginFail:^{
            [subscriber sendError:[SonaError errWithCode:SNCodeZegoEnterFail]];
            [subscriber sendCompleted];
        }];
        return nil;
    }] retry:3];
}

- (void)ensureLogin:(void (^)(void))action loginFail:(void (^)(void))failBlock {
    if (self.isLoginRoom) {
        if (action) {
            action();
        }
    } else {
        [[self enter:true] subscribeNext:^(id x) {
            if (action) {
                action();
            }
        } error:^(NSError *error) {
            if (failBlock) {
                failBlock();
            }
        }];
    }
}

- (RACSignal *)startPullMixedStream {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        NSString *streamUrl = [self streamId];
        NSString *desc = @"Zego Start Pull Mixed";
        ZegoAPIStreamExtraPlayInfo *extraInfo = [ZegoAPIStreamExtraPlayInfo new];
        extraInfo.mode = CDN_ONLY;
        [self.signpost begin:SRRoomSorakaLogPullMixedDuration ext:@{SRRoomSorakaLogDescKey: desc}];
        [self.zegoApi startPlayingStream:streamUrl inView:nil extraInfo:extraInfo];
        SN_LOG_LOCAL(@"%@, streamUrl: %@",desc, streamUrl);
        if (streamUrl) {
            [self.pullingStreamsMSet addObject:streamUrl];
            [subscriber sendNext:@(SNCodeZegoStartPullMultiStreamSuccess)];
        } else {
            [subscriber sendError:[SonaError errWithCode:SNCodeZGPullMixStreamFail]];
        }
        [subscriber sendCompleted];
        return nil;
    }];
}

- (RACSignal *)startPullAllId {
    if ([self.pullMode isEqualToString:SN_STREAM_PULL_MODE_MULTI]) {
        NSArray *argArr = [self.zegoStreamsMSet allObjects];
        [self.zegoStreamsMSet enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, BOOL * _Nonnull stop) {
            NSString *accId = [self.zegoStreamMDic valueForKey:obj];
            if (accId) {
                [self.pullingAccIdMSet addObject:accId];
            }
        }];
        return [self startPullWithIdArr:argArr];
    } else if ([self.pullMode isEqualToString:SN_STREAM_PULL_MODE_MIXED]) {
        return [self startPullMixedStream];
    } else {
        return [RACSignal empty];
    }
}


- (RACSignal *)stopPullWithId:(NSString *)stream {
    return [self stopPullWithIdArr:@[stream]];
}

- (RACSignal *)stopPullWithIdArr:(NSArray <NSString *> *)streamsArr {
    @weakify(self);
    return [[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        @strongify(self)
        SN_LOG_LOCAL(@"Zego Stop Pull Mutil, streamIds:%@", streamsArr);
        for (NSString *stream in streamsArr) {
            BOOL contains = [self.pullingStreamsMSet containsObject:stream];
            if (!contains) {
                continue;
            }
            
            if ([self.zegoApi stopPlayingStream:stream]) {
                [self clearVideoStreamId:stream];
                [self.pullingStreamsMSet removeObject:stream];
            } else {
                SN_LOG_LOCAL(@"Zego Stop Pull Mutil Fail, streamId: %@", stream);
                [subscriber sendError:[SonaError errWithCode:SNCodeZegoStopPullMultiStreamFail]];
                [subscriber sendCompleted];
            }
        }
        SN_LOG_LOCAL(@"Zego Stop Pull Mutil Success, streamIds: %@", streamsArr);
        [subscriber sendNext:@(SNCodeZegoStopPullMultiStreamSuccess)];
        [subscriber sendCompleted];
        return nil;
    }] retry:3];
}

- (RACSignal *)stopPullMixedStream {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        NSString *streamUrl = [self streamId];
        [self.zegoApi stopPlayingStream:streamUrl];
        [self clearVideoStreamId:streamUrl];
        SN_LOG_LOCAL(@"Zego Stop Pull Mixed, streamId: %@", streamUrl);
        if (streamUrl) {
            [self.pullingStreamsMSet removeObject:streamUrl];
            SN_LOG_LOCAL(@"Zego Stop Pull Mixed Success, streamId: %@", streamUrl);
            [subscriber sendNext:@(SNCodeZGStopPullMixStreamSuccess)];
            [subscriber sendCompleted];
        } else {
            SN_LOG_LOCAL(@"Zego Stop Pull Mixed Fail, streamId: %@", streamUrl);
            [subscriber sendError:[SonaError errWithCode:SNCodeZGStopPullMixStreamFail]];
            [subscriber sendCompleted];
        }
        return nil;
    }];
}

- (RACSignal *)stopPullAllId {
    if ([self.pullMode isEqualToString:SN_STREAM_PULL_MODE_MULTI]) {
        NSArray *argArr = [self.pullingStreamsMSet allObjects];
        [self.pullingAccIdMSet removeAllObjects];
        return [self stopPullWithIdArr:argArr];
    } else if ([self.pullMode isEqualToString:SN_STREAM_PULL_MODE_MIXED]) {
        return [self stopPullMixedStream];
    } else {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
            return nil;
        }];
    }
}

- (RACSignal *)enableMic {
    return [self switchMicWith:YES];
}

- (RACSignal *)unableMic {
    return [self switchMicWith:NO];
}
    
- (RACSignal *)switchMicWith:(BOOL)flag {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        @strongify(self)
        NSString *str = flag ? @"Zego Enable Mic" : @"Zego Unable Mic";
        SN_LOG_LOCAL(@"%@", str);

        if ([self.zegoApi enableMic:flag]) {
            str = [str stringByAppendingString:@" Success"];
            SN_LOG_LOCAL(@"%@", str);
            [subscriber sendNext:@(SNCodeZegoMicSuccess)];
        } else {
            str = [str stringByAppendingString:@" Fail"];
            [subscriber sendError:[SonaError errWithCode:SNCodeZegoMicFail]];
        }
        [subscriber sendCompleted];
        return nil;
    }];
}

- (RACSignal *)enableSpeaker {
    return [self switchSpeakerWithFlag:YES];
}

- (RACSignal *)unableSpeaker {
    return [self switchSpeakerWithFlag:NO];
}

- (RACSignal *)switchSpeakerWithFlag:(BOOL)flag {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        NSString *str = flag ? @"Zego Enable Speaker" : @"Zego Unable Speaker";
        SN_LOG_LOCAL(@"%@", str);
        if ( [self.zegoApi setBuiltInSpeakerOn:flag]) {
            str = [str stringByAppendingString:@" Success"];
            SN_LOG_LOCAL(@"%@", str);
            [subscriber sendNext:@(SNCodeZGSpeakerSuccess)];
        } else {
            str = [str stringByAppendingString:@" Fail"];
            SN_LOG_LOCAL(@"%@", str);
            [subscriber sendError:[SonaError errWithCode:SNCodeZGSpeakerFail]];
        }
        [subscriber sendCompleted];
        return nil;
    }];
}

- (RACSignal *)muteWithId:(NSString *)stream {
    return [self switchMuteWithStreamArr:@[stream] flag:YES];
}

- (RACSignal *)unMuteWithId:(NSString *)stream {
    return [self switchMuteWithStreamArr:@[stream] flag:NO];
}

- (RACSignal *)muteWithIdArr:(NSArray<NSString *> *)streamArr {
    return [self switchMuteWithStreamArr:streamArr flag:YES];
}

- (RACSignal *)unMuteWithIdArr:(NSArray<NSString *> *)streamArr {
    return [self switchMuteWithStreamArr:streamArr flag:NO];
}

- (RACSignal *)switchMuteWithStreamArr:(NSArray<NSString *> *)streamArr flag:(BOOL)flag {
    @weakify(self);
    return [[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        @strongify(self)
        NSString *str = flag ? @"Zego Mute" : @"Zego Unmute";
        SN_LOG_LOCAL(@"%@", str);
        for (NSString *stream in streamArr) {
            BOOL contains = [self.pullingStreamsMSet containsObject:stream];
            if (!contains) {
                [subscriber sendError:[SonaError errWithCode:SNCodeZegoMuteFail]];
            }
            int vol = flag ? 0 : 100;
            if (![self.zegoApi setPlayVolume:vol ofStream:stream]) {
                str = [str stringByAppendingString:@" Fail"];
                SN_LOG_LOCAL(@"%@", str);
                [subscriber sendError:[SonaError errWithCode:SNCodeZegoMuteFail]];
            }
        }
        str = [str stringByAppendingString:@" Success"];
        SN_LOG_LOCAL(@"%@", str);
        [subscriber sendNext:@(SNCodeZegoMuteSuccess)];
        [subscriber sendCompleted];
        return nil;
    }] retry:3];
}

- (BOOL)isPullingWithId:(NSString *)stream {
    return [self.pullingStreamsMSet containsObject:stream];
}

- (NSSet<NSString *> *)pullingAccIdSet {
    NSSet *result = [[NSSet alloc] initWithSet:self.pullingAccIdMSet];
    return result;
}
- (NSSet<NSString *> *)allStreamSet {
    NSSet *result = [[NSSet alloc] initWithSet:self.zegoStreamsMSet];
    return result;
}

- (RACSignal *)isPullingSignal {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        bool flag = self.pullingStreamsMSet.count > 0 ? YES : NO;
        [subscriber sendNext:@(flag)];
        [subscriber sendCompleted];
        return nil;
    }];
}

- (RACSignal *)isPublishingSignal {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        [subscriber sendNext:@(self.publishing)];
        [subscriber sendCompleted];
        return nil;
    }];
}

- (BOOL)isPublishing {
    return self.publishing;
}

- (BOOL)enableLoopback {
    BOOL result = [self.zegoApi enableLoopback:true];
    return result;
}

- (BOOL)disableLoopback {
    BOOL result = [self.zegoApi enableLoopback:false];
    return result;
}

- (BOOL)setReverbMode:(SNVoiceReverbMode)mode {
    BOOL isSuccess = [ZegoAudioProcessing setReverbPreset:(ZegoAPIVoiceReverbType)mode];
    SN_LOG_LOCAL(@"zego enable reverb %d, mode:%d", isSuccess, (int)mode);
    return isSuccess;
}

- (void)setStreamRenderView:(UIView *)view {
    self.streamView = view;
    SN_LOG_LOCAL(@"set stream render view: %@", view.description);
    if (!view) {
        // 如果view不存在，则立即更新。如果view存在，需要等到 onVideoRenderCallback 回调后设置
        [self.zegoApi updatePlayView:nil ofStream:self.lastVideoStreamId];
        self.lastVideoStreamId = nil;
    }
}

- (void)setCaptureVolume:(NSInteger)volume {
    SN_LOG_LOCAL(@"set capture volume, %@", @(volume));
    [self.zegoApi setCaptureVolume:(int)volume];
}

- (NSInteger)getCaptureVolume {
    return (NSInteger)[self.zegoApi getCaptureSoundLevel];
}

- (void)setLoopbackVolume:(NSInteger)volume {
    SN_LOG_LOCAL(@"set loopback volume, %@", @(volume));
    [self.zegoApi setLoopbackVolume:(int)volume];
}

- (RACSignal *)uploadSDKLog {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [ZegoLiveRoomApi uploadLog];
        [subscriber sendNext:nil];
        [subscriber sendCompleted];
        return nil;
    }];
}

- (void)clearCollectionData {
    [self.zegoStreamsMSet removeAllObjects];
    [self.pullingStreamsMSet removeAllObjects];
    [self.pullingAccIdMSet removeAllObjects];
    [self.zegoStreamMDic removeAllObjects];
    
    self.publishingStream = @"";
}

- (void)destroyPlayer {
    if (_mediaPlayer) {
        dispatch_async(self.destroyPlayerQueue, ^{
            [self.mediaPlayer destroyPlayer];
            SN_LOG_LOCAL(@"Sona Logan: destroy media player");
        });
    }
    if (_zegoMediaPlayer) {
        dispatch_async(self.destroyPlayerQueue, ^{
            [self.zegoMediaPlayer stop];
            [self.zegoMediaPlayer setEventWithIndexDelegate:nil];
            [self.zegoMediaPlayer uninit];
            self.zegoMediaPlayer = nil;
            SN_LOG_LOCAL(@"Sona Logan: destroy media player(index 0)");
        });
    }
}

- (void)setDeviceMode:(SRDeviceMode)mode {
    switch (mode) {
        case SRDeviceModeGeneral:
            [ZegoLiveRoomApi setAudioDeviceMode:ZEGOAPI_AUDIO_DEVICE_MODE_GENERAL];
            break;
        case SRDeviceModeCommunication:
            [ZegoLiveRoomApi setAudioDeviceMode:ZEGOAPI_AUDIO_DEVICE_MODE_COMMUNICATION3];
            break;
        default:
            [ZegoLiveRoomApi setAudioDeviceMode:ZEGOAPI_AUDIO_DEVICE_MODE_GENERAL];
            break;
    }
    SN_LOG_LOCAL(@"Sona Logan: set device mode %@", @(mode));
}

#pragma mark - Audio Preprocess

- (void)setAudioPrep:(id<SNAudioPrepProtocol>)processor {
    [self.audioPrepProxy enableAudioPreprocess:processor];
}

- (void)removeAudioPrep:(id<SNAudioPrepProtocol>)processor {
    [self.audioPrepProxy disableAudioPreprocess:processor];
}

- (SNZGAudioPrepProxy *)audioPrepProxy {
    if (!_audioPrepProxy) {
        _audioPrepProxy = [[SNZGAudioPrepProxy alloc] initWithZegoApi:self.zegoApi];
    }
    return _audioPrepProxy;
}

#pragma mark - Zego delegate

- (void)onStreamUpdated:(int)type streams:(NSArray<ZegoStream *> *)streamList roomID:(NSString *)roomID {
    if ([roomID isEqualToString:[self.configModel.productConfig.streamConfig.streamRoomId snStringForKey:@"ZEGO"]]) {
        if (type == ZEGO_STREAM_ADD) {
            NSMutableArray *mArr = [NSMutableArray new];
            NSMutableArray <NSString *> *idMArr = [NSMutableArray new];
            for (ZegoStream *zgStream in streamList) {
                [mArr addObject:zgStream.streamID];
                [idMArr addObject:zgStream.userID];
                
                [self.zegoStreamsMSet addObject:zgStream.streamID];
                [self.zegoStreamMDic setValue:zgStream.userID forKey:zgStream.streamID];
            
                [self.pullingAccIdMSet addObjectsFromArray:idMArr];
                if ([self.pullMode isEqualToString:SN_STREAM_PULL_MODE_MULTI]) {
                    [[self startPullWithIdArr:mArr] subscribeNext:^(id x) {
                    }];
                }
            }
        } else if (type == ZEGO_STREAM_DELETE) {
            NSMutableArray *mArr = [NSMutableArray new];
            NSMutableArray <NSString *> *idMArr = [NSMutableArray new];
            for (ZegoStream *zgStream in streamList) {
                [mArr addObject:zgStream.streamID];
                [idMArr addObject:zgStream.userID];
                [self.zegoStreamsMSet removeObject:zgStream.streamID];
                [self.zegoStreamMDic removeObjectForKey:zgStream.streamID];
            }
            if (self.zegoStreamsMSet.count == 0) {
                [self.onNeedCheckConfig sendNext:@1];
            }
            [idMArr enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.pullingAccIdMSet removeObject:obj];
            }];
            if ([self.pullMode isEqualToString:SN_STREAM_PULL_MODE_MULTI]) {
                
                [[self stopPullWithIdArr:mArr] subscribeNext:^(id x) {
                }];
            }
        }
    }
}

- (void)onPublishStateUpdate:(int)stateCode streamID:(NSString *)streamID streamInfo:(NSDictionary<NSString *, NSArray<NSString *> *> *)info {
    if (stateCode != 0) {
        self.publishing = false;
        SN_LOG_LOCAL(@"Zego Start Publish Fail, streamId:%@, sdkCode: %@", streamID, @(stateCode));
        
        BOOL trying = [self.audioRetry retryToPublishStream:streamID];
        if (!trying) {
            NSDictionary *ext = @{@"streamID": streamID ? : @""};
            [self.onPublishStreamFail sendNext:RACTuplePack(@(stateCode), ext)];
        }
    } else {
        [self.onPublishStreamSuccess sendNext: streamID ? : @""];
    }
}


- (void)onPublishQualityUpdate:(NSString *)streamID quality:(ZegoApiPublishQuality)quality {
    if (self.lastPublishAudioBitrate <= 0 && quality.akbps > 0) {
        [self.publishEventCallback sendNext:@(SNPublishEventMicRecover)];
    }
    if (self.lastPublishAudioBitrate > 0 && quality.akbps <= 0) {
        [self.publishEventCallback sendNext:@(SNPublishEventMicSeize)];
    }
    self.lastPublishAudioBitrate = quality.akbps;
}

- (void)onPlayStateUpdate:(int)stateCode streamID:(NSString *)streamID {
    BOOL isMixStream = [self.pullMode isEqualToString:SN_STREAM_PULL_MODE_MIXED];
    if (stateCode != 0) {
        SN_LOG_LOCAL(@"Zego Start Pull Stream Fail, streamId:%@, sdkCode:%@", streamID, @(stateCode));
        
        // 混流模式下，对于不存在的流，无限重试。(业务场景：空房间)
        if (isMixStream && [self isStreamNotExist:stateCode]) {
            [[self startPullMixedStream] subscribeNext:^(id x) {}];
            [self.onNeedCheckConfig sendNext:@1];
        } else {
            BOOL trying = [self.audioRetry checkAndRetryToPullStream:streamID isMixed:isMixStream];
            if (trying) {
                // 重试中，先不用向上抛，也不做日志上报
                return;
            }
            SNAudioStreamType type = isMixStream ? SNAudioStreamTypeMixed : SNAudioStreamTypeMulti;
            NSDictionary *ext = @{@"streamID": streamID ? : @"",
                                  @"streamType":@(type)};
            [self.onPullStreamFail sendNext:RACTuplePack(@(stateCode), ext)];
        }
    } else {
        if (isMixStream) {
            [self.signpost end:SRRoomSorakaLogPullMixedDuration];
        } else {
            [self.signpost end:SRRoomSorakaLogPullMultiDuration spid:streamID];
        }
        BOOL enableVideoRender = [ZegoExternalVideoRender enableVideoRender:true streamID:streamID];
        SN_LOG_LOCAL(@"Zego Start Pull Stream Success, sdkCode:%@, streamId:%@, vrnd:%@", @(stateCode), streamID, @(enableVideoRender));
        [self.onPullStreamSuccess sendNext:streamID ? : @""];
    }
}


- (void)onReconnect:(int)errorCode roomID:(NSString *)roomID {
    if ([roomID isEqualToString:[self.configModel.productConfig.streamConfig.streamRoomId snStringForKey:@"ZEGO"]]) {
        if (errorCode == 0) {
            [self.reconnectSubject sendNext:@(YES)];
        }
        SN_LOG_LOCAL(@"zego reconn, code: %@",@(errorCode));
    }
}

- (void)onTempBroken:(int)errorCode roomID:(NSString *)roomID {
    if ([roomID isEqualToString:[self.configModel.productConfig.streamConfig.streamRoomId snStringForKey:@"ZEGO"]]) {
        if (errorCode != 0) {
            [self.disconnectSubject sendNext:@(errorCode)];
        }
        SN_LOG_LOCAL(@"zego temp borken, code: %@",@(errorCode));
    }
}

- (void)onDisconnect:(int)errorCode roomID:(NSString *)roomID {
    if ([roomID isEqualToString:[self.configModel.productConfig.streamConfig.streamRoomId snStringForKey:@"ZEGO"]]) {
        if (errorCode != 0) {
            self.entered = false;
            self.loginRoom = false;
            [self.disconnectSubject sendNext:@(errorCode)];
            SN_LOG_LOCAL(@"zego disconn, code: %@",@(errorCode));
        }
    }
}

- (NSInteger)getAudioStreamCount {
    return [self.zegoMediaPlayer getAudioStreamCount];
}

- (BOOL)setAudioStream:(SNPlayerAudioStreamIndex)index {
    long result = [self.zegoMediaPlayer setAudioStream:(int)index];
    return result == 0;
}

- (void)onCaptureSoundLevelUpdate:(ZegoSoundLevelInfo *)captureSoundLevel {
    if ([captureSoundLevel.streamID isEqualToString:self.publishingStream] && captureSoundLevel.soundLevel > 1) {
        [self.volumeSubject sendNext:@(captureSoundLevel.soundLevel)];
    }
}

- (void)onSoundLevelUpdate:(NSArray<ZegoSoundLevelInfo *> *)soundLevels {
    if ([self.pullMode isEqualToString:SN_STREAM_PULL_MODE_MULTI]) {
        for (ZegoSoundLevelInfo *info in soundLevels) {
            NSString *accId = [self.zegoStreamMDic snStringForKey:info.streamID];
            if (info.soundLevel > 1 && accId.length) {
                [self.voiceApertureSubject sendNext:@{@"idenType" : @"streamId", @"result" : accId}];
            }
        }
    }
}

- (void)onSoundLevelInMixedStream:(NSArray<ZegoSoundLevelInMixedStreamInfo *> *)soundLevelListt {
    if ([self.pullMode isEqualToString:SN_STREAM_PULL_MODE_MIXED]) {
        NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:self.dateForFrequency] * 1000;
        if(duration > 500) {
            for (ZegoSoundLevelInMixedStreamInfo *info in soundLevelListt) {
                if ((int)info.soundLevel > 1) {
                    if (info.soundLevelID) {
                        [self.voiceApertureSubject sendNext:@{@"idenType" : @"yppno", @"result" : @(info.soundLevelID)}];
                    }
                }
            }
            self.dateForFrequency = [NSDate date];
        }
    }
}

- (void)onVideoRenderCallback:(unsigned char **)data dataLen:(int *)dataLen width:(int)width height:(int)height strides:(int [])strides pixelFormat:(VideoPixelFormat)pixelFormat streamID:(NSString *)streamID {
    if (width < 50 || height < 50) {
        // Ignore Fake Video Frame
        return;
    }
    if (![self.lastVideoStreamId isEqualToString:streamID] && self.streamView) {
        [self.zegoApi updatePlayView:self.streamView ofStream:streamID];
        self.lastVideoStreamId = streamID;
        if (self.isFirstRender) {
            self.firstRender = false;
            [self.videoFirstRenderCallback sendNext:@1];
            [self.videoFirstRenderCallback sendCompleted];
        }
    }
}

- (void)onKickOut:(int)reason roomID:(NSString *)roomID customReason:(NSString *)customReason {
    if (![self isCurrentRoom:roomID]) {
        return;
    }
    [self.onKickOutRoom sendNext:@(reason)];
    SN_LOG_LOCAL(@"zego kick out, roomId: %@, reason: %@", roomID, @(reason));
}

#pragma mark - SEI

- (void)sendSEIMessageWithDataDict:(NSDictionary *)dataDict {
    [self.seiService sendMessage:dataDict];
}

- (void)onReceiveSeiMessage:(NSDictionary *)message streamId:(NSString *)streamId {
    if (!streamId.length) {
        SN_LOG_LOCAL(@"SEI-streamId is nil");
        return;
    }
    [self.onReceiveMediaSideInfo sendNext:@{streamId : message ?: @{}}];
}

#pragma mark Properties

- (ZegoStreamMixer *)streamMixer {
    if (!_streamMixer) {
        _streamMixer = [ZegoStreamMixer new];
    }
    return _streamMixer;
}

- (ZegoMediaPlayer *)zegoMediaPlayer {
    if (!_zegoMediaPlayer) {
        _zegoMediaPlayer = [[ZegoMediaPlayer alloc] initWithPlayerType:MediaPlayerTypePlayer
                                                           playerIndex:ZegoMediaPlayerIndexFirst];
        [_zegoMediaPlayer setVolume:100];
        [_zegoMediaPlayer setProcessInterval:1000];
        [_zegoMediaPlayer requireHWDecoder];
        [_zegoMediaPlayer setEventWithIndexDelegate:self];
    }
    return _zegoMediaPlayer;
}

- (RACSubject *)volumeSubject {
    if (!_volumeSubject) {
        _volumeSubject = [RACSubject new];
    }
    return _volumeSubject;
}

- (RACSubject *)disconnectSubject {
    if (!_disconnectSubject) {
        _disconnectSubject = [RACSubject new];
    }
    return _disconnectSubject;
}
- (RACSubject *)reconnectSubject {
    if (!_reconnectSubject) {
        _reconnectSubject = [RACSubject new];
    }
    return _reconnectSubject;
}

- (RACSignal *)voiceApertureSubject {
    if (!_voiceApertureSubject) {
        _voiceApertureSubject = [RACSubject new];
    }
    return _voiceApertureSubject;
}

- (RACSubject *)publishEventCallback {
    if (!_publishEventCallback) {
        _publishEventCallback = [RACSubject subject];
    }
    return _publishEventCallback;
}

- (id<SNMediaPlayer>)auxPlayer {
    return self.mediaPlayer.auxPlayer;
}

- (id<SNMediaPlayer>)localPlayer {
    return self.mediaPlayer.localPlayer;
}


- (id<SNPCMPlayer>)pcmPlayer {
    return self.mediaPlayer.pcmPlayer;
}

- (SNZGMediaPlayer *)mediaPlayer {
    if (!_mediaPlayer) {
        _mediaPlayer = [SNZGMediaPlayer new];
        _mediaPlayer.proxy = self;
        _mediaPlayer.zegoApi = self.zegoApi;
    }
    return _mediaPlayer;
}

//- (ZegoMediaSideInfo *)mediaSideInfo {
//    if (!_mediaSideInfo) {
//        _mediaSideInfo = [ZegoMediaSideInfo new];
//        [_mediaSideInfo setMediaSideDelegate:self];
//        [_mediaSideInfo setMediaSideFlags:true
//                         onlyAudioPublish:false
//                            mediaInfoType:SideInfoZegoDefined
//                              seiSendType:SeiSendInVideoFrame
//                             channelIndex:ZEGOAPI_CHN_MAIN];
//    }
//    return _mediaSideInfo;
//}

- (RACSubject *)onReceiveMediaSideInfo {
    if (!_onReceiveMediaSideInfo) {
        _onReceiveMediaSideInfo = [RACSubject new];
    }
    return _onReceiveMediaSideInfo;
}

- (RACSubject *)videoFirstRenderCallback {
    if (!_videoFirstRenderCallback) {
        _videoFirstRenderCallback = [RACSubject subject];
    }
    return _videoFirstRenderCallback;
}

- (NSMutableArray *)loginObservers {
    if (!_loginObservers) {
        _loginObservers = [NSMutableArray new];
    }
    return _loginObservers;
}

- (RACSubject *)onPullStreamFail {
    if (!_onPullStreamFail) {
        _onPullStreamFail = [RACSubject subject];
    }
    return _onPullStreamFail;
}

- (RACSubject *)onKickOutRoom {
    if (!_onKickOutRoom) {
        _onKickOutRoom = [RACSubject subject];
    }
    return _onKickOutRoom;
}

- (RACSubject *)onPullStreamSuccess {
    if (!_onPullStreamSuccess) {
        _onPullStreamSuccess = [RACSubject subject];
    }
    return _onPullStreamSuccess;
}

- (RACSubject *)onPublishStreamFail {
    if (!_onPublishStreamFail) {
        _onPublishStreamFail = [RACSubject subject];
    }
    return _onPublishStreamFail;
}

- (RACSubject *)onPublishStreamSuccess {
    if (!_onPublishStreamSuccess) {
        _onPublishStreamSuccess = [RACSubject subject];
    }
    return _onPublishStreamSuccess;
}

- (RACSubject *)onNeedCheckConfig {
    if (!_onNeedCheckConfig) {
        _onNeedCheckConfig = [RACSubject subject];
    }
    return _onNeedCheckConfig;
}

#pragma mark - private

- (NSString *)streamId {
    return self.configModel.productConfig.streamConfig.streamId;
}

- (NSString *)streamUrl {
    return self.configModel.productConfig.streamConfig.streamUrl;
}

- (NSString *)roomID {
    return [self.configModel.productConfig.streamConfig.streamRoomId snStringForKey:@"ZEGO"];
}

- (BOOL)isCurrentRoom:(NSString *)roomID {
    return [roomID isEqualToString:[self roomID]];
}

- (BOOL)shouldLogin {
    // 需要登录的场景：
    // 1. 拉多流
    return [self.pullMode isEqualToString:SN_STREAM_PULL_MODE_MULTI];
}

- (NSTimeInterval)currentTimestamp {
    return floor([[NSDate date] timeIntervalSince1970] * 1000);
}
    
- (void)clearVideoStreamId:(NSString *)stream {
    if ([self.lastVideoStreamId isEqualToString:stream]) {
        self.lastVideoStreamId = nil;
    }
}

- (BOOL)isStreamNotExist:(NSInteger)sdkCode {
    return sdkCode == 12200006 || sdkCode == 12102001 || sdkCode == 12200201;
}


@end

