//
//  SNTXAudio.m
//  SonaSDK
//
//  Created by Insomnia on 2020/3/4.
//

#import "SNTXAudio.h"
#import "SNMacros.h"
#import <TXLiteAVSDK_Professional/TXLiteAVSDK.h>
#import "SNSubjectCleaner.h"
#import "SNLoggerHelper.h"
#import "SNEventSignpost.h"
#import "SNTXAudioPrepProxy.h"
#import "SNTXMediaPlayer.h"
#import "SNThreadSafeSet.h"

typedef NS_ENUM(NSInteger, SNTXCallbackType) {
    SNTXCallbackTypeEnter = 0,
    SNTXCallbackTypeLeave = 1,
    SNTXCallbackTypeSwitchRole = 2,
};

static NSString * const SNOutputVolumeKey = @"outputVolume";
static const int32_t MusicIndex = 1;

@interface SNTXAudio () <TRTCCloudDelegate, TXLivePlayListener, TRTCAudioFrameDelegate>
@property(nonatomic, strong, readwrite) TRTCCloud *cloudPlayer;
@property(nonatomic, strong, readwrite) TXLivePlayer *livePlayer;
@property(nonatomic, strong, readwrite) SNConfigModel *configModel;

@property(atomic, assign) BOOL publishing;
@property(nonatomic, assign) BOOL entered;
@property(nonatomic, copy) NSString *publishingStream;

@property(nonatomic, strong) SNThreadSafeSet *txAccIdMSet;
@property(nonatomic, strong) SNThreadSafeSet *pullingAccIdMSet;

@property(nonatomic, copy) NSString *bgmPath;
@property(nonatomic, strong) RACSubject *volumeSubject;
@property (nonatomic, strong) RACSubject *voiceApertureSubject;
@property(nonatomic, strong) RACSubject *disconnectSubject;
@property(nonatomic, strong) RACSubject *reconnectSubject;
@property(nonatomic, strong) RACSubject *delegateSubject;
@property (nonatomic, strong) RACSubject *onReceiveMediaSideInfo;
@property (nonatomic, strong) RACSubject *videoFirstRenderCallback;

@property (nonatomic, strong) RACSubject *onPublishStreamFail;
@property (nonatomic, strong) RACSubject *onPublishStreamSuccess;
@property (nonatomic, strong) RACSubject *onPullStreamFail;
@property (nonatomic, strong) RACSubject *onPullStreamSuccess;
@property (nonatomic, strong) RACSubject *onNeedCheckConfig;

@property (nonatomic, strong) RACSubject *onKickOutRoom;

@property (nonatomic, assign) BOOL isStopBgm;

@property (nonatomic, assign) BOOL txRoomEnteredAction;

@property (nonatomic, copy) NSString *pullMode;

@property (atomic, assign, getter=isMuteOutputVolume) BOOL muteOutputVolume;

@property (nonatomic, strong) SNEventSignpost *signpost;

@property (nonatomic, strong) SNTXAudioPrepProxy *audioPrepProxy;

@property (nonatomic, assign) NSInteger volumeLogCount;

@property (nonatomic, strong) SNTXMediaPlayer *mediaPlayer;

@end

@implementation SNTXAudio

- (instancetype)initWithConfigModel:(SNConfigModel *)configModel {
    self = [super init];
    if (self) {
        self.configModel = configModel;
        self.pullMode = configModel.productConfig.streamConfig.pullMode;
        [self setup];
        [self onInitSDK];
        [self onAfterInitSDK];
        [self setupVolumeObserver];
    }
    return self;
}

- (void)dealloc {
    if (_cloudPlayer) {
        _cloudPlayer = nil;
    }
    if (_livePlayer) {
        _livePlayer = nil;
    }
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
        if (!self.cloudPlayer) {
            SN_LOG_LOCAL(@"Sona Logan: cloudPlayer not exist");
            return;
        }
        CGFloat newVolume = [newValue floatValue];
        if (newVolume <= 0) {
            self.muteOutputVolume = true;
            [self.cloudPlayer setAudioPlayoutVolume:0];
            SN_LOG_LOCAL(@"Sona Logan: disableSpeaker");
        }
        if (newVolume > 0 && self.isMuteOutputVolume) {
            self.muteOutputVolume = false;
            [self.cloudPlayer setAudioPlayoutVolume:100];
            SN_LOG_LOCAL(@"Sona Logan: enableSpeaker");
        }
    }];
}

- (void)setup {
    self.signpost = [SNEventSignpost new];
    
    [self setupCollections];
}

- (void)setupCollections {
    self.txAccIdMSet = [SNThreadSafeSet new];
    self.pullingAccIdMSet = [SNThreadSafeSet new];
}

- (void)onInitSDK {
    self.cloudPlayer = [TRTCCloud sharedInstance];
    self.cloudPlayer.delegate = self;
    [self.cloudPlayer setAudioFrameDelegate:self.audioPrepProxy];
    [self.cloudPlayer enableAudioVolumeEvaluation:300];
    NSDictionary *exprimentalAPIDict = @{@"api":@"forceCallbackMixedPlayAudioFrame",
                                         @"params":@{@"enable":@1}};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:exprimentalAPIDict options:NSJSONWritingPrettyPrinted error:nil];
    NSString *exprimentalAPI = nil;
    if (jsonData) {
        exprimentalAPI = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    if (exprimentalAPI) {
        [self.cloudPlayer callExperimentalAPI:exprimentalAPI];
    }
    
    TRTCAudioFrameDelegateFormat *format = [TRTCAudioFrameDelegateFormat new];
    format.sampleRate = TRTCAudioSampleRate44100;
    format.channels = 2;
    format.samplesPerCall = 441;
    [self.cloudPlayer setMixedPlayAudioFrameDelegateFormat:format];
    
    [self.cloudPlayer setAudioRoute:TRTCAudioModeSpeakerphone];
    [self.cloudPlayer setSystemVolumeType:TRTCSystemVolumeTypeMedia];
    
    self.livePlayer = [TXLivePlayer new];
    TXLivePlayConfig *config = [TXLivePlayConfig new];
    [config setConnectRetryCount:2];
    [config setMinAutoAdjustCacheTime:1.5];
    [config setMaxAutoAdjustCacheTime:4.5];
    [config setEnableMessage:true];
    self.livePlayer.config = config;
    self.livePlayer.delegate = self;
    @weakify(self)
    [self.livePlayer setAudioVolumeEvaluationListener:^(int volume) {
        @strongify(self)
        self.volumeLogCount++;
        if (self.volumeLogCount >= 15) {
            [self.livePlayer enableAudioVolumeEvaluation:0];
        }
        SN_LOG_LOCAL(@"Sona Logan: tx audio volume %@", @(volume));
    }];
    [self.livePlayer enableAudioVolumeEvaluation:1000];
}

- (void)onAfterInitSDK {
    // 提前初始化AME播放器，因为第一次下载 License 会比较久
    [self musicPlayer];
    // 初始化媒体播放器
    self.mediaPlayer = [SNTXMediaPlayer new];
    self.mediaPlayer.manager = [self.cloudPlayer getAudioEffectManager];
}

#pragma mark Override

- (RACSignal *)updateConfigModel:(SNConfigModel *)configModel {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        @strongify(self)
        self.configModel = configModel;
        // 如果当前是单流，不再更新。
        if (![self.pullMode isEqualToString:SN_STREAM_PULL_MODE_MULTI]) {
            self.pullMode = configModel.productConfig.streamConfig.pullMode;
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
    return [[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        @strongify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            SN_LOG_LOCAL(@"TX Enter %@, streamRoomId: %@", self.configModel.productConfig.productCode, [self streamRoomId]);
            [self resetProperty];
            if (isForce || [self.pullMode isEqualToString:SN_STREAM_PULL_MODE_MULTI]) {
                if (self.txRoomEnteredAction) {
                    SN_LOG_LOCAL(@"TX Enter Success(login) %@, streamRoomId: %@", self.configModel.productConfig.productCode, [self streamRoomId]);
                    [subscriber sendNext:@(SNCodeTXEnterSuccess)];
                    [subscriber sendCompleted];
                } else {
                    TRTCParams *params = [self paramsWith:self.configModel.productConfig.streamConfig.streamId];
                    [self.signpost begin:SRRoomSorakaLogAudioLoginDuration spid:[self streamRoomId] ext:@{SRRoomSorakaLogDescKey: @"TX Enter Duration"}];
                    [self.cloudPlayer enterRoom:params appScene:TRTCAppSceneLIVE];
                    [self.cloudPlayer muteAllRemoteAudio:YES];
                    // 设置mic状态
                    [[self switchMicMuteWith:!self.configModel.micEnabled] subscribeNext:^(id x) {
                    }];
                    self.txRoomEnteredAction = YES;
                    
                    __block BOOL flag = YES;

                    [self.delegateSubject subscribeNext:^(RACTuple *tuple) {
                        @strongify(self)
                        if (flag) {
                            @strongify(self);
                            RACTupleUnpack(NSNumber *type, NSNumber *res) = tuple;
                            if ([type integerValue] == SNTXCallbackTypeEnter) {
                                if ([res integerValue] > 0) {
                                    self.entered = YES;
                                    [self.signpost end:SRRoomSorakaLogAudioLoginDuration spid:[self streamRoomId]];
                                    SN_LOG_LOCAL(@"TX Enter Success, streamRoomId: %@", [self streamRoomId]);
                                    [subscriber sendNext:@(SNCodeTXEnterSuccess)];
                                } else {
                                    self.entered = NO;
                                    SN_LOG_LOCAL(@"TX Enter Fail, streamRoomId:%@",[self streamRoomId]);
                                    [subscriber sendError:[SonaError errWithCode:SNCodeTXEnterFail]];
                                }
                                [subscriber sendCompleted];
                                flag = NO;
                            }
                        }
                    }];
                }
            } else if ([self.pullMode isEqualToString:SN_STREAM_PULL_MODE_MIXED]) {
                self.entered = YES;
                SN_LOG_LOCAL(@"TX Enter Success(no need login), streamRoomId:%@",[self streamRoomId]);
                [subscriber sendNext:@(SNCodeTXEnterSuccess)];
                [subscriber sendCompleted];
            }
        });
        return nil;
    }] retry:3];
}

- (RACSignal *)reEnter {
    return [self enter];
}

- (void)ensureLogin:(void (^)(void))action loginFail:(void (^)(void))failBlock {
    if (self.txRoomEnteredAction) {
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

- (BOOL)beenEntered {
    return self.entered;
}

- (TRTCParams *)paramsWith:(NSString *)streamId {
    TRTCParams *params = [TRTCParams new];
    params.sdkAppId = (UInt32)[self.configModel.attMDic snIntegerForKey:@"appId"];
    params.userId = self.configModel.uid;
    params.userSig =     [self.configModel.attMDic snStringForKey:@"sig"];

    params.roomId = (UInt32) [[self streamRoomId] integerValue];
    params.role = TRTCRoleAudience;

    NSDictionary *dic;
    if (streamId.length > 0) {
        dic = @{
                @"userdefine_streamid_main": streamId,
                @"pure_audio_push_mod": @(2),
        };
    } else {
        dic = @{
                @"pure_audio_push_mod": @(2),
        };
    }
    NSDictionary *info = @{
            @"Str_uc_params": dic
    };

    params.bussInfo = [info mj_JSONString];

    return params;
}

- (RACSignal *)leave {
    @weakify(self);
    SN_LOG_LOCAL(@"TX Leave %@", [self streamRoomId]);
    return [[[[self stopPullAllId] flattenMap:^RACStream *(id value) {
        @strongify(self);
        return [self stopPublish];
    }] flattenMap:^RACStream *(id value) {
        @strongify(self);
        return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
            @strongify(self);
            [self.audioPrepProxy closeAudioPreprocess];
            [self.pcmPlayer destroy];
            if ([self.pullMode isEqualToString:SN_STREAM_PULL_MODE_MIXED]) {
                [self.livePlayer stopPlay];
                self.entered = false;
                SN_LOG_LOCAL(@"TX Leave Success %@", [self streamRoomId]);
                [SNSubjectCleaner clear:self];
                [subscriber sendNext:@(SNCodeTXLeaveSuccess)];
                [subscriber sendCompleted];
            } else {
                [[self.cloudPlayer getAudioEffectManager] stopPlayMusic:MusicIndex];
                [self.cloudPlayer exitRoom];
                self.txRoomEnteredAction = NO;
                __block BOOL flag = YES;
                [self.delegateSubject subscribeNext:^(RACTuple *tuple) {
                    @strongify(self)
                    if (flag) {
                        RACTupleUnpack(NSNumber *type, NSNumber *res) = tuple;
                        if ([type integerValue] == SNTXCallbackTypeLeave) {
                            if (![res integerValue]) {
                                self.entered = false;
                                SN_LOG_LOCAL(@"TX Leave Success %@", [self streamRoomId]);
                                [subscriber sendNext:@(SNCodeTXLeaveSuccess)];
                            } else {
                                SN_LOG_LOCAL(@"TX Leave Fail %@", [self streamRoomId]);
                                [subscriber sendError:[SonaError errWithCode:SNCodeTXLeaveFail]];
                            }
                            [SNSubjectCleaner clear:self];
                            [subscriber sendCompleted];
                            flag = NO;
                        }
                    }
                }];
            }
            return nil;
        }];
    }] retry:3];
}

- (RACSignal *)startPublishWithId:(NSString *)stream {
    stream = stream ? : @"";
    @weakify(self);
    return [[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        @strongify(self)
        [self ensureLogin:^{
            @strongify(self)
            SN_LOG_LOCAL(@"TX Publish, streamId: %@", stream);
            [self.cloudPlayer startPublishing:stream type:TRTCVideoStreamTypeBig];
            [self.cloudPlayer switchRole:TRTCRoleAnchor];
            self.pullMode = SN_STREAM_PULL_MODE_MULTI;
            // 接收 回调 标志位
            __block BOOL flag = YES;
            [self.delegateSubject subscribeNext:^(RACTuple *tuple) {
                @strongify(self)
                if (flag) {
                    RACTupleUnpack(NSNumber *type, NSNumber *res) = tuple;
                    if ([type integerValue] == SNTXCallbackTypeSwitchRole) {
                        if ([res integerValue] == ERR_NULL) {
                            [self.cloudPlayer enableAudioVolumeEvaluation:300];
                            [self.cloudPlayer startLocalAudio:TRTCAudioQualityMusic];
                            self.publishing = YES;
                            self.publishingStream = stream;
                            SN_LOG_LOCAL(@"TX Publish Success, streamId: %@", [self streamRoomId]);
                            [subscriber sendNext:@(SNCodeTXPublishStreamSuccess)];
                        } else {
                            SN_LOG_LOCAL(@"TX Publish Fail, streamId: %@", [self streamRoomId]);
                            [subscriber sendError:[SonaError errWithCode:SNCodeTXPublishStreamFail]];
                        }
                        [subscriber sendCompleted];
                        flag = NO;
                    }
                }
            }];
        } loginFail:^{
            [subscriber sendError:[SonaError errWithCode:SNCodeTXEnterFail]];
        }];
        return nil;
    }] retry:3];
}

- (RACSignal *)stopPublish {
    @weakify(self);
    return [[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        @strongify(self)
        if (!self.publishing) {
            [subscriber sendNext:@(SNCodeTXStopPublishSuccess)];
        } else {
            [self.cloudPlayer switchRole:TRTCRoleAudience];
            [self.cloudPlayer stopLocalAudio];
            self.publishing = NO;
            self.publishingStream = nil;
            SN_LOG_LOCAL(@"TX Stop Publish Success");
            [subscriber sendNext:@(SNCodeTXStopPublishSuccess)];
        }
        [subscriber sendCompleted];
        return nil;
    }] retry:3];
}

- (RACSignal *)startPullWithId:(NSString *)idStr {
    return [self startPullWithIdArr:@[idStr]];
}

- (RACSignal *)startPullWithIdArr:(NSArray<NSString *> *)idArr {
    return [self switchMuteWithAccIdArr:idArr flag:NO];
}

- (RACSignal *)startPullMixedStream {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            SN_LOG_LOCAL(@"TX Start Pull Mixed, streamId:%@", [self streamId]);
            if (![self.livePlayer stopPlay]) {
                [self.livePlayer startLivePlay:self.configModel.productConfig.streamConfig.streamUrl type:PLAY_TYPE_LIVE_FLV];
                [self.signpost begin:SRRoomSorakaLogPullMixedDuration spid:[self streamRoomId] ext:@{SRRoomSorakaLogDescKey:@"TX Pull Mixed Duration"}];
                SN_LOG_LOCAL(@"TX Start Pull Mixed Success, streamId:%@", [self streamId]);
                [subscriber sendNext:@(SNCodeTXPullMixStreamSuccess)];
            } else {
                SN_LOG_LOCAL(@"TX Start Pull Mixed Fail, streamId:%@", [self streamId]);
                [subscriber sendError:[SonaError errWithCode:SNCodeTXPullMixStreamFail]];
            }
            [subscriber sendCompleted];
        });
        return nil;
    }];
}

- (RACSignal *)startPullAllId {
    if ([self.pullMode isEqualToString:SN_STREAM_PULL_MODE_MULTI]) {
        return [self switchAllStreamMuteWithFlag:NO];
    } else if ([self.pullMode isEqualToString:SN_STREAM_PULL_MODE_MIXED]) {
        return [self startPullMixedStream];
    } else {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
            return nil;
        }];
    }
}

- (RACSignal *)stopPullWithId:(NSString *)stream {
    return [self stopPullWithIdArr:@[stream]];
}

- (RACSignal *)stopPullWithIdArr:(NSArray<NSString *> *)streamsArr {
    return [self switchMuteWithAccIdArr:streamsArr flag:YES];
}

- (RACSignal *)stopPullMixedStream {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            SN_LOG_LOCAL(@"TX Stop Pull Mixed, streamId:%@", [self streamId]);
            if (![self.livePlayer stopPlay]) {
                SN_LOG_LOCAL(@"TX Stop Pull Mixed Success, streamId:%@", [self streamId]);
                [subscriber sendNext:@(SNCodeTXStopPullMixStreamSuccess)];
            } else {
                SN_LOG_LOCAL(@"TX Stop Pull Mixed Fail, streamId:%@", [self streamId]);
                [subscriber sendError:[SonaError errWithCode:SNCodeTXStopPullMixStreamFail]];
            }
            [subscriber sendCompleted];
        });
        return nil;
    }];
}

- (RACSignal *)stopPullAllId {
    if ([self.pullMode isEqualToString:SN_STREAM_PULL_MODE_MULTI]) {
        return [self switchAllStreamMuteWithFlag:YES];
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

- (RACSignal *)switchAllStreamMuteWithFlag:(BOOL)flag {
    @weakify(self)
    return [[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        @strongify(self)
        NSString *str = flag ? @"TX Start Pull Mutil" : @"TX Stop Pull Mutil";
        SN_LOG_LOCAL(@"%@", str);
        [self.cloudPlayer muteAllRemoteAudio:flag];
        if (flag) {
            [self.pullingAccIdMSet removeAllObjects];
        }
        SNCode code = flag == YES ? SNCodeTXStartPullMultiStreamSuccess : SNCodeTXStopPullMultiStreamSuccess;
        str = [str stringByAppendingString:@" Success"];
        SN_LOG_LOCAL(@"%@", str);
        [subscriber sendNext:@(code)];
        [subscriber sendCompleted];
        return nil;
    }] retry:3];
}

- (void)muteAllRemoteUser:(BOOL)mute {
    [self.cloudPlayer muteAllRemoteAudio:mute];
}

- (RACSignal *)enableMic {
    return [self switchMicMuteWith:NO];
}

- (RACSignal *)unableMic {
    return [self switchMicMuteWith:YES];
}

- (RACSignal *)switchMicMuteWith:(BOOL)flag {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        @strongify(self)
        [self.cloudPlayer muteLocalAudio:flag];
        [subscriber sendNext:@(SNCodeTXMicSuccess)];
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
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        TRTCAudioRoute route = flag ? TRTCAudioModeSpeakerphone : TRTCAudioModeEarpiece;
        [self.cloudPlayer setAudioRoute:route];
        [subscriber sendNext:@(SNCodeTXSpeakerSuccess)];
        [subscriber sendCompleted];
        return nil;
    }];
}

- (RACSignal *)muteWithId:(NSString *)stream {
    return [self switchMuteWithAccIdArr:@[stream] flag:YES];
}

- (RACSignal *)unMuteWithId:(NSString *)stream {
    return [self switchMuteWithAccIdArr:@[stream] flag:NO];
}

- (RACSignal *)muteWithIdArr:(NSArray<NSString *> *)idArr {
    return [self switchMuteWithAccIdArr:idArr flag:YES];
}

- (RACSignal *)unMuteWithIdArr:(NSArray<NSString *> *)idArr {
    return [self switchMuteWithAccIdArr:idArr flag:NO];
}

- (RACSignal *)switchMuteWithAccIdArr:(NSArray<NSString *> *)uidArr flag:(BOOL)flag {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        @strongify(self)
        for (NSString *uid in uidArr) {
            if ([uid isEqualToString:self.configModel.uid]) {
                continue;
            }
            if (flag) {
                [self.pullingAccIdMSet removeObject:uid];
            } else {
                [self.pullingAccIdMSet addObject:uid];
            }
            [self.cloudPlayer muteRemoteAudio:uid mute:flag];
        }
        SNCode code = flag == YES ? SNCodeTXStartPullMultiStreamSuccess : SNCodeTXStopPullMultiStreamSuccess;
        [subscriber sendNext:@(code)];
        [subscriber sendCompleted];
        return nil;
    }];
}

- (BOOL)isPullingWithId:(NSString *)idStr {
    return [self.pullingAccIdMSet containsObject:idStr];
}

- (NSSet<NSString *> *)pullingAccIdSet {
    return self.pullingAccIdMSet;
}

- (NSSet<NSString *> *)allStreamSet {
    return self.pullingAccIdMSet;
}

- (RACSignal *)isPullingSignal {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        @strongify(self)
        bool flag = self.pullingAccIdMSet.count > 0 ? YES : NO;
        [subscriber sendNext:@(flag)];
        [subscriber sendCompleted];
        return nil;
    }];
}

- (RACSignal *)isPublishingSignal {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        @strongify(self)
        [subscriber sendNext:@(self.publishing)];
        [subscriber sendCompleted];
        return nil;
    }];
}

- (BOOL)isPublishing {
    return self.publishing;
}

- (NSInteger)getAudioStreamCount {
    return 0;
}

- (BOOL)setAudioStream:(SNPlayerAudioStreamIndex)index {
    return true;
}

- (RACSignal *)uploadSDKLog {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:nil];
        [subscriber sendCompleted];
        return nil;
    }];
}

- (BOOL)enableLoopback {
    [[self.cloudPlayer getAudioEffectManager] enableVoiceEarMonitor:true];
    return true;
}

- (BOOL)disableLoopback {
    [[self.cloudPlayer getAudioEffectManager] enableVoiceEarMonitor:false];
    return true;
}

- (BOOL)setReverbMode:(SNVoiceReverbMode)mode {
    return false;
}

- (void)setStreamRenderView:(UIView *)view {
    
}

- (NSInteger)getCaptureVolume {
    return -1;
}

- (void)setCaptureVolume:(NSInteger)volume {
    [[self.cloudPlayer getAudioEffectManager] setVoiceVolume:volume];
}

- (void)setLoopbackVolume:(NSInteger)volume {
    [[self.cloudPlayer getAudioEffectManager] setVoiceEarMonitorVolume:volume];
}

- (void)resetProperty {
    [self.txAccIdMSet removeAllObjects];
    [self.pullingAccIdMSet removeAllObjects];
    self.publishingStream = @"";
}

- (void)processEventMessage:(NSDictionary *)params {
    if (![params isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    NSData *data = [params objectForKey:@"EVT_GET_MSG"];
    NSError *error = nil;
    NSDictionary *paramsFromBytes = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (!error) {
        [self updateVoiceApearture:paramsFromBytes];
    } else {
        // handle error
    }
}

- (void)updateVoiceApearture:(NSDictionary *)params {
    NSArray *regions = [params snArrayForKey:@"regions"];
    [regions enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[NSDictionary class]]) {
            return;
        }
        NSString *accId = [obj snStringForKey:@"uid"];
        NSInteger volume = [obj snIntegerForKey:@"volume"];
        if (volume > 1) {
            [self.voiceApertureSubject sendNext:@{@"idenType" : @"streamId", @"result" : accId}];
        }
    }];
}

- (id<SNMediaPlayer>)localPlayer {
    return self.mediaPlayer.localPlayer;
}

- (id<SNMediaPlayer>)auxPlayer {
    return self.mediaPlayer.auxPlayer;
}

- (id<SNPCMPlayer>)pcmPlayer {
    return self.audioPrepProxy;
}

- (void)setDeviceMode:(SRDeviceMode)mode {
    
}

#pragma mark - TRTCCloudDelegate

- (void)onEnterRoom:(NSInteger)result {
    if (result < 0) {
        self.entered = NO;
    }
    RACTuple *tuple = RACTuplePack(@(SNTXCallbackTypeEnter), @(result));
    [self.delegateSubject sendNext:tuple];
}

- (void)onSwitchRole:(TXLiteAVError)errCode errMsg:(NSString *)errMsg {
    RACTuple *tuple = RACTuplePack(@(SNTXCallbackTypeSwitchRole), @(errCode));
    [self.delegateSubject sendNext:tuple];
}

- (void)onRemoteUserLeaveRoom:(NSString *)userId reason:(NSInteger)reason {
    [self.txAccIdMSet removeObject:userId];
    [self.pullingAccIdMSet removeObject:userId];
    if (self.pullingAccIdSet.count == 0) {
        [self.onNeedCheckConfig sendNext:@1];
        
    }
}

- (void)onRemoteUserEnterRoom:(NSString *)userId {
    [self.txAccIdMSet addObject:userId];
    [self.pullingAccIdMSet addObject:userId];
    [self.signpost begin:SRRoomSorakaLogPullMultiDuration spid:userId ext:@{SRRoomSorakaLogDescKey:@"TX Pull Multi Duration"}];
}

- (void)onExitRoom:(NSInteger)reason {
    RACTuple *tuple = RACTuplePack(@(SNTXCallbackTypeLeave), @(reason));
    self.txRoomEnteredAction = false;
    [self.delegateSubject sendNext:tuple];
}

- (void)onNetStatus:(NSDictionary *)param {
}

- (void)onStopPublishing:(int)err errMsg:(NSString *)errMsg {
    if (err != 0) {
        SN_LOG_LOCAL(@"TX Stop Push Fail, streamId:%@, error:%@", [self streamId], errMsg);
    }
}

- (void)onError:(TXLiteAVError)errCode errMsg:(NSString *)errMsg extInfo:(NSDictionary *)extInfo {
    if (errCode == ERR_SPEAKER_START_FAIL) {
        SN_LOG_LOCAL(@"TX Start Speaker Fail, streamRoomId:%@, error:%@", [self streamId], errMsg);
    }
}

// 拉多流时，麦上用户的音量回调
- (void)onUserVoiceVolume:(NSArray<TRTCVolumeInfo *> *)userVolumes totalVolume:(NSInteger)totalVolume {
    if (!userVolumes.count) {
        return;
    }
    for (int i = 0; i < userVolumes.count; i++) {
        TRTCVolumeInfo *info = userVolumes[i];
        if (info.volume <= 1) {
            return;
        }
        if (!info.userId.length) {
            [self.volumeSubject sendNext:@(info.volume)];
        } else {
            [self.voiceApertureSubject sendNext:@{@"idenType" : @"streamId", @"result" : info.userId}];
        }
    }
}

- (void)onFirstAudioFrame:(NSString *)userId {
    [self.signpost end:SRRoomSorakaLogPullMultiDuration spid:userId];
}

#pragma mark - TXLivePlayListener

// 拉混流时，事件的回调
- (void)onPlayEvent:(int)EvtID withParam:(NSDictionary *)param {
    
    if (EvtID == PLAY_EVT_PLAY_BEGIN) {
        [self.signpost end:SRRoomSorakaLogPullMixedDuration spid:[self streamRoomId]];
        return;
    }
    
    if (EvtID == WARNING_RTMP_DNS_FAIL || EvtID == WARNING_RTMP_SEVER_CONN_FAIL || EvtID == WARNING_RTMP_SHAKE_FAIL || EvtID == WARNING_RTMP_SERVER_BREAK_CONNECT) {
        if ([self.pullMode isEqualToString:SN_STREAM_PULL_MODE_MIXED]) {
            [self.onNeedCheckConfig sendNext:@1];
            [[self startPullMixedStream] subscribeNext:^(id x) {}];
        }
    } else if (EvtID == ERR_PLAY_LIVE_STREAM_NET_DISCONNECT) {
        [self.disconnectSubject sendNext:@(EvtID)];
        if ([self.pullMode isEqualToString:SN_STREAM_PULL_MODE_MIXED]) {
            [self.onNeedCheckConfig sendNext:@1];
            [[self startPullMixedStream] subscribeNext:^(id x) {}];
        }
    } else if (EvtID == PLAY_WARNING_RECONNECT) {
        [self.reconnectSubject sendNext:@(EvtID)];
    } else if (EvtID == PLAY_EVT_GET_MESSAGE) {
        [self processEventMessage: param];
    }
}

#pragma mark - Audio Preprocess

- (void)setAudioPrep:(id<SNAudioPrepProtocol>)processor {
    [self.audioPrepProxy enableAudioPreprocess:processor];
}

- (void)removeAudioPrep:(id<SNAudioPrepProtocol>)processor {
    [self.audioPrepProxy disableAudioPreprocess:processor];
}

#pragma mark Properties

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

- (RACSubject *)publishEventCallback {
    return [RACSubject subject];
}

- (RACSubject *)delegateSubject {
    if (!_delegateSubject) {
        _delegateSubject = [RACSubject new];
    }
    return _delegateSubject;
}

- (RACSignal *)voiceApertureSubject {
    if (!_voiceApertureSubject) {
        _voiceApertureSubject = [RACSubject new];
    }
    return _voiceApertureSubject;
}

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

- (SNTXAudioPrepProxy *)audioPrepProxy {
    if (!_audioPrepProxy) {
        _audioPrepProxy = [SNTXAudioPrepProxy new];
    }
    return _audioPrepProxy;
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
    return self.configModel.productConfig.streamConfig.streamUrl ? : @"";
}

- (NSString *)streamRoomId {
    return [self.configModel.productConfig.streamConfig.streamRoomId snStringForKey:SN_STREAM_SUPPLIER_TENCENT];
}

@end
