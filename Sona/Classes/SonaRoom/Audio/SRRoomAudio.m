//
//  SRRoomAudio.m
//  SonaRoom
//
//  Created by Insomnia on 2019/12/14.
//

#import "SRRoomAudio.h"
#import "SRMuteStreamUserCommand.h"
#import "SRUnMuteStreamUserCommand.h"
#import "SRSpecificStreamCommand.h"
#import "SRSpecificNotStreamCommand.h"
#import "SRStreamRoomListRequestSignal.h"
#import "SNSDK.h"
#import "SRGenUserSigSignal.h"
#import "SRStreamChangeSignal.h"
#import "SRMonitorStreamReqSig.h"
#import "SNCode.h"
#import "SRRemixStreamRequestSignal.h"
#import "SRStreamMixVideoRequestSignal.h"
#import "SNConfigPollingService.h"
#import "SRSyncConfigModel.h"

#import "SRRebootServiceManager.h"
#import "SNLoggerHelper.h"
#import "NSDictionary+SNProtectedKeyValue.h"

@interface SRRoomAudio ()
@property(nonatomic, strong) SNSDK *sdk;
@property(nonatomic, strong) SNConfigModel *configModel;
@property (nonatomic, strong) SRRebootServiceManager *rebootService;

/** 是否可以由风控消息开启推流 */
@property(nonatomic, assign) BOOL isPublishByRisk;

@property(nonatomic, strong, readwrite) RACSubject *configSubject;
/** 推流用stream id */
@property(nonatomic, copy) NSString *streamId;

@property (nonatomic, strong) SNConfigPollingService *pollingService;

@property (nonatomic, strong) RACSubject *wrapVoiceApertureSubject;

@property (nonatomic, strong) RACSubject *wrapVolumeSubject;

@property (nonatomic, copy) NSString *lastSupplier;

@property (nonatomic, copy) NSString *lastPullMode;

@property (atomic, assign) BOOL hasStopPolling;

@end


@implementation SRRoomAudio
- (instancetype)initWithTuple:(RACTuple *)tuple {
    self = [SRRoomAudio new];
    if (self) {
        RACTupleUnpack(SNSDK *sdk, SNConfigModel *configModel) = tuple;
        self.sdk = sdk;
        [self updateConfigWithModel:configModel];
        [self setup];
    }
    return self;
}

- (void)setup {
    [self handleMsg];
    [self observePublishQuality];
    [self initConfigPollingService];
    [self initRebootService];
}

- (BOOL)beenEntered {
    return [self.sdk.audio beenEntered];
}

- (void)setAudioPrep:(id<SNAudioPrepProtocol>)processor {
    [self.rebootService.audioPrepReboot addProcessor:processor];
    return [self.sdk.audio setAudioPrep:processor];
}

- (void)removeAudioPrep:(id<SNAudioPrepProtocol>)processor {
    [self.rebootService.audioPrepReboot removeProcessor:processor];
    [self.sdk.audio removeAudioPrep:processor];
}

- (RACSignal *)enableMic {
    return [self.sdk.audio enableMic];
}

- (RACSignal *)unableMic {
    return [self.sdk.audio unableMic];
}

- (RACSignal *)enableSpeaker {
    return [self.sdk.audio enableSpeaker];
}

- (RACSignal *)unableSpeaker {
    return [self.sdk.audio unableSpeaker];
}

- (RACSignal *)muteWithIdArr:(NSArray<NSString *> *)idArr {
    return [self.sdk.audio muteWithIdArr:idArr];
}

- (RACSignal *)muteWithId:(NSString *)idStr {
    return [self.sdk.audio muteWithId:idStr];
}

- (RACSignal *)unMuteWithIdArr:(NSArray<NSString *> *)idArr {
    return [self.sdk.audio unMuteWithIdArr:idArr];
}

- (RACSignal *)unMuteWithId:(NSString *)idStr {
    return [self.sdk.audio unMuteWithId:idStr];
}

- (RACSignal *)startPullSpecificWithModel:(SRSpecificStreamModel *)model {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        model.roomId = self.configModel.roomId;

        SRSpecificStreamCommand *command = [SRSpecificStreamCommand new];
        [command.requestCommond.executionSignals.switchToLatest subscribeNext:^(id x) {
            [subscriber sendNext:x];
            [subscriber sendCompleted];
        }];
        
        [command.requestCommond.errors subscribeNext:^(id x) {
            [subscriber sendError:x];
            [subscriber sendCompleted];
        }];
        
        [command.requestCommond execute:model];
        
        return nil;
    }];
}

- (RACSignal *)stopPullSpecificWithModel:(SRSpecificNotStreamModel *)model {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {

        model.roomId = self.configModel.roomId;

        SRSpecificNotStreamCommand *command = [SRSpecificNotStreamCommand new];
        [command.requestCommond.executionSignals.switchToLatest subscribeNext:^(id x) {
            [subscriber sendNext:x];
            [subscriber sendCompleted];
        }];
        
        [command.requestCommond.errors subscribeNext:^(id x) {
            [subscriber sendError:x];
            [subscriber sendCompleted];
        }];
        
        [command.requestCommond execute:model];
        
        return nil;
    }];
}

- (RACSignal *)isPullingSignal {
    return [self.sdk.audio isPullingSignal];
}

- (RACSignal *)isPublishingSignal {
    return [self.sdk.audio isPublishingSignal];
}

- (BOOL)isPullingWithId:(NSString *)idStr {
    return [self.sdk.audio isPullingWithId:idStr];
}

- (NSSet <NSString *> *)pullingAccIdSet {
    return [self.sdk.audio pullingAccIdSet];
}

- (RACSignal *)startPublish {
    if ([self.lastPullMode isEqualToString:SN_STREAM_PULL_MODE_MIXED]) {
        return [self startMixedPublish];
    } else if ([self.lastPullMode isEqualToString:SN_STREAM_PULL_MODE_MULTI]) {
        return [self startMultiPublish];
    } else {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
            return nil;
        }];
    }
}

- (RACSignal *)startMixedPublish {
    @weakify(self);
    return [[self.sdk.audio stopPullAllId] flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
        @strongify(self);
        return [[self.sdk.audio enter] flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
            @strongify(self);
            return [[self startMultiPublish] flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
                @strongify(self);
                return [self startPullAllId];
            }];
        }];
    }];
}

- (RACSignal *)startMultiPublish {
    @weakify(self);
    return [[self generateStream] flattenMap:^__kindof RACSignal * _Nullable(NSString *stream) {
        @strongify(self);
        return [[self.sdk.audio startPublishWithId:stream] flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                self.lastPullMode = SN_STREAM_PULL_MODE_MULTI;
                [self.pollingService startPolling:true];
                NSDictionary *arg = @{
                    @"streamId" : self.streamId,
                    @"roomId" : self.configModel.roomId,
                    @"type" : @(1)
                };
                [[SRStreamChangeSignal streamChangeWith:arg] subscribeNext:^(id x) {
                }];
                [subscriber sendNext:stream];
                [subscriber sendCompleted];
                return nil;
            }];
        }];
    }];
}

- (RACSignal *)generateStream {
    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        // 产品码 + connector + 云商  + connector + sonaSdkVersion + connector + 发起端 + connector + roomId + connector + uid + connector + 随机数;
        NSString *ret = @"";
        ret = [ret stringByAppendingFormat:@"%@_", self.configModel.productConfig.productCodeAlias];
        NSString *supp = [self.configModel.productConfig.streamConfig.supplier isEqualToString:SN_STREAM_SUPPLIER_ZEGO] ? @"Z" : @"T";
        ret = [ret stringByAppendingFormat:@"%@_", supp];
        ret = [ret stringByAppendingString:@"3_"];
        ret = [ret stringByAppendingString:@"2_"];
        ret = [ret stringByAppendingFormat:@"%@_", self.configModel.roomId];
        ret = [ret stringByAppendingFormat:@"%@_", self.configModel.uid];
        NSTimeInterval inter = [[NSDate date] timeIntervalSince1970] * 1000;
        NSString *dStr = [NSString stringWithFormat:@"%@", @([[NSNumber numberWithDouble:inter] integerValue])];
        ret = [ret stringByAppendingString:dStr];
        
        while (ret.length < 64) {
            ret = [ret stringByAppendingString:@"0"];
        }

        self.streamId = ret;
        
        [subscriber sendNext:self.streamId];
        [subscriber sendCompleted];
        
        return nil;
    }];
}

- (RACSignal *)streamIdList {
    return [SRStreamRoomListRequestSignal StreamRoomListWithRoomId:self.configModel.roomId];
}

- (RACSignal *)stopPublish {
    if (self.streamId.length > 0) {
        NSDictionary *arg = @{
            @"streamId" : self.streamId,
            @"roomId" : self.configModel.roomId,
            @"type" : @(2)
        };
        self.streamId = @"";
        [[SRStreamChangeSignal streamChangeWith:arg] subscribeNext:^(id x) {
        }];
    }
    [self.pollingService stopPolling];
    return [self.sdk.audio stopPublish];
}

- (RACSignal *)startPullAllId {
    return [self.sdk.audio startPullAllId];
}

- (RACSignal *)stopPullAllId {
    return [self.sdk.audio stopPullAllId];
}

- (RACSignal *)startPullWithId:(NSString *)idStr {
    return [self startPullWithIdArr:@[idStr]];
}

- (RACSignal *)startPullWithIdArr:(NSArray<NSString *> *)idArr {
    return [self.sdk.audio startPullWithIdArr:idArr];
}

- (RACSignal *)stopPullWithId:(NSString *)idStr {
    return [self stopPullWithIdArr:@[idStr]];
}

- (RACSignal *)stopPullWithIdArr:(NSArray<NSString *> *)idArr {
    return [self.sdk.audio stopPullWithIdArr:idArr];
}


- (BOOL)setReverbMode:(SNVoiceReverbMode)mode {
    return [self.sdk.audio setReverbMode:mode];
}

- (BOOL)enableLoopback {
    return [self.sdk.audio enableLoopback];
}

- (BOOL)disableLoopback {
    return [self.sdk.audio disableLoopback];
}

- (RACSubject *)onReceiveMediaSideInfo {
    return [self.sdk.audio onReceiveMediaSideInfo];
}

- (RACSignal *)muteStreamUserWithModel:(SRMuteStreamUserModel *)model {
    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        SRMuteStreamUserCommand *command = [SRMuteStreamUserCommand new];
        model.roomId = self.configModel.roomId;
        [command.requestCommond.executionSignals.switchToLatest subscribeNext:^(NSNumber *res) {
            [subscriber sendNext:res];
            [subscriber sendCompleted];
        }];

        [command.requestCommond.errors subscribeNext:^(id x) {
            [subscriber sendError:x];
            [subscriber sendCompleted];
        }];
        [command.requestCommond execute:model];
        return nil;
    }];
}

- (RACSignal *)unMuteStreamUserWithModel:(SRUnMuteStreamUserModel *)model {
    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        SRUnMuteStreamUserCommand *command = [SRUnMuteStreamUserCommand new];
        model.roomId = self.configModel.roomId;
        [command.requestCommond.executionSignals.switchToLatest subscribeNext:^(NSNumber *res) {
            [subscriber sendNext:res];
            [subscriber sendCompleted];
        }];

        [command.requestCommond.errors subscribeNext:^(id x) {
            [subscriber sendError:x];
            [subscriber sendCompleted];
        }];
        [command.requestCommond execute:model];
        return nil;
    }];
}

- (RACSubject *)volumeSubject {
    return self.wrapVolumeSubject;
}

- (RACSubject *)disconnectSubject {
    return [self.sdk.audio disconnectSubject];
}

- (RACSubject *)reconnectSubject {
    return [self.sdk.audio reconnectSubject];
}

- (RACSignal *)voiceApertureSubject {
    
    return self.wrapVoiceApertureSubject;
}

- (RACSubject *)publishEventCallback {
    return [self.sdk.audio publishEventCallback];
}

- (NSInteger)getCaptureVolume {
    return [self.sdk.audio getCaptureVolume];
}

- (void)setCaptureVolume:(NSInteger)volume {
    [self.sdk.audio setCaptureVolume:volume];
}

- (void)setLoopbackVolume:(NSInteger)volume {
    [self.sdk.audio setLoopbackVolume:volume];
}

- (void)setStreamRenderView:(UIView *)view {
    [self.sdk.audio setStreamRenderView:view];
}

- (RACSignal *)reEnter {
    return [self.sdk.audio reEnter];
}

- (void)observePublishQuality {
    @weakify(self)
    [[[self publishEventCallback] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        @strongify(self)
        if ([x intValue] == SNPublishEventMicRecover) {
            [[SRRemixStreamRequestSignal remixStream:self.configModel.roomId] subscribeNext:^(id x) {
                SN_LOG_LOCAL(@"remix success");
            } error:^(NSError *error) {
                SN_LOG_LOCAL(@"remix error, %@", error);
            }];
        }
    }];
}

- (void)handleMsg {
    @weakify(self);
    [self.sdk.conn.msgSubject subscribeNext:^(SNMsgModel *msgModel) {
        @strongify(self);
        if (![msgModel.roomId isEqualToString:self.configModel.roomId]) {
            return;
        }
        
        if ([msgModel.msgType integerValue] == SNMsgTypeSwitch) {
            SNMsgSwitchModel *model = [[SNMsgSwitchModel alloc] mj_setKeyValues:msgModel.data];
            [self handleSwitchMsgWithModel:model];
        }
    }];
}

- (void)handleSwitchMsgWithModel:(SNMsgSwitchModel *)model {
    @weakify(self)
    if ([model.roomId isEqualToString:self.configModel.roomId]) {
        if (![self.lastSupplier isEqualToString:model.supplier] ||
            (!self.sdk.audio.isPublishing && ![self.lastPullMode isEqualToString:model.pullMode])) {
            self.lastSupplier = model.supplier;
            self.lastPullMode = model.pullMode;
            [[SRGenUserSigSignal genUserSignalWith:@{@"roomId" : self.configModel.roomId}] subscribeNext:^(SRGenUserSigResModel *genRes) {
                [[[[self isPublishingSignal] flattenMap:^__kindof RACSignal * _Nullable(NSNumber *res) {
                    BOOL isPublish = [res boolValue];
                    return [[[self.sdk.audio leave] flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
                        @strongify(self)
                        self.configModel.productConfig.streamConfig.supplier = model.supplier;
                        self.configModel.productConfig.streamConfig.pullMode = model.pullMode;
                        self.configModel.productConfig.streamConfig.pushMode = model.pushMode;
                        self.configModel.productConfig.streamConfig.streamUrl = model.streamUrl;
                        self.configModel.productConfig.streamConfig.bitrate = model.bitrate;
                        [self.configModel.attMDic setValue:@(genRes.appId) forKey:@"appId"];
                        
                        SN_LOG_LOCAL(@"Switch audio to %@ pull mode %@", model.supplier, model.pullMode);
                        
                        if ([self.configModel.productConfig.streamConfig.supplier isEqualToString:SN_STREAM_SUPPLIER_ZEGO]) {
                            NSString *sigString = genRes.appSign;
                            NSArray <NSString *> *arr = [sigString componentsSeparatedByString:@","];
                            NSInteger len = arr.count;
                            Byte byteArr[10000] = {0};
                            for (int i = 0; i < len; i++) {
                                int num = [self numberWithHexString:arr[i]];
                                byteArr[i] = num;
                            }
                            
                            if (arr.count == 32) {
                                NSData *sig = [[NSData alloc] initWithBytes:byteArr length:len];
                                [self.configModel.attMDic setValue:sig forKey:@"sig"];
                            }
                            
                            self.configModel.productConfig.streamConfig.streamId = model.streamId.length > 0 ? model.streamId : self.configModel.productConfig.streamConfig.streamId;
                        } else if ([self.configModel.productConfig.streamConfig.supplier isEqualToString:SN_STREAM_SUPPLIER_TENCENT]) {
                            NSString *sigString = genRes.appSign;
                            [self.configModel.attMDic setValue:sigString forKey:@"sig"];
                            self.configModel.productConfig.streamConfig.streamUrl = model.streamUrl.length > 0 ? model.streamUrl : self.configModel.productConfig.streamConfig.streamUrl;
                        }
                        
                        [self.configSubject sendNext:self.configModel];
                        if (self.hasStopPolling) {
                            SN_LOG_LOCAL(@"Sona Logan: has stop polling");
                            return [RACSignal return:@1];
                        }
                        return [[self.sdk updateConfigModel:self.configModel] flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
                            @strongify(self)
                            return [[self.sdk.audio enter] flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
                                @strongify(self)
                                [self initConfigPollingService];
                                [self subscribeInnerVoiceAperture];
                                [self subscribeInnerVolumeSubject];
                                //TODO: 目前只考虑推流前启动的功能，如果有需要推流后启动的，可以在service里面细分
                                [self.rebootService reboot];
                                return [[self.sdk.audio startPullAllId] flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
                                    @strongify(self)
                                    SN_LOG_LOCAL(@"Switch audio success to %@ pull mode %@", model.supplier, model.pullMode);
                                    if (isPublish) {
                                        return [self startPublish];
                                    } else {
                                        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                                            [subscriber sendNext:nil];
                                            [subscriber sendCompleted];
                                            return nil;
                                        }];
                                    }
                                }];
                            }];
                        }];
                    }] catch:^RACSignal *(NSError *error) {
                        [self updateLastConfig];
                        return [RACSubject return:error];
                    }];
                }] retry:3]  subscribeNext:^(id x) {
                }];
            } error:^(NSError *error) {
                [self updateLastConfig];
            }];
        } else {
            SN_LOG_LOCAL(@"Sona Logan: no need A switch, supplier:%@-%@, publish: %@, pullmode: %@-%@", self.configModel.productConfig.streamConfig.supplier,model.supplier, @(self.sdk.audio.isPublishing), self.configModel.productConfig.streamConfig.pullMode, model.pullMode);
        }
    }
}

- (void)handleStreamMuteMsgWithModel:(SNMsgStreamMuteModel *)model {
    if (model.isMute) {
        NSMutableArray *tmpMArr = [NSMutableArray new];
        for (SNMsgStreamMuteItemModel *item in model.streamList) {
            NSString *idStr = [self.configModel.productConfig.streamConfig.supplier isEqualToString:SN_STREAM_SUPPLIER_ZEGO] ? item.streamId : item.accId;
            [tmpMArr addObject:idStr];
        }
        if (tmpMArr.count > 0) {
            [[self muteWithIdArr:tmpMArr] subscribeNext:^(id x) {
            }];
        }
    } else {
        // Trick logic
        NSMutableArray *tmpMArr = [NSMutableArray new];
        for (SNMsgStreamMuteItemModel *item in model.streamList) {
            NSString *idStr = [self.configModel.productConfig.streamConfig.supplier isEqualToString:SN_STREAM_SUPPLIER_ZEGO] ? item.streamId : item.accId;
            [tmpMArr addObject:idStr];
        }
        if (tmpMArr.count > 0) {
            [[self startPullWithIdArr:tmpMArr] subscribeNext:^(id x) {
            }];
        }
    }
}

- (int)numberWithHexString:(NSString *)hexString{
    const char *hexChar = [hexString cStringUsingEncoding:NSUTF8StringEncoding];
    int hexNumber;
    sscanf(hexChar, "%x", &hexNumber);
    return hexNumber;
}

- (void)updateConfigWithModel:(SNConfigModel *)model {
    self.configModel = model;
    [self updateLastConfig];
}

- (void)updateLastConfig {
    self.lastSupplier = self.configModel.productConfig.streamConfig.supplier;
    self.lastPullMode = self.configModel.productConfig.streamConfig.pullMode;
    SN_LOG_LOCAL(@"Sona Logan: last config %@-%@",self.lastSupplier, self.lastPullMode);
}

- (RACSubject *)videoFirstRenderCallback {
    return [self.sdk.audio videoFirstRenderCallback];
}

- (void)subscribeInnerVoiceAperture {
    @weakify(self)
    [self.sdk.audio.voiceApertureSubject subscribeNext:^(id x) {
        @strongify(self)
        [self.wrapVoiceApertureSubject sendNext:x];
    }];
}

- (void)subscribeInnerVolumeSubject {
    @weakify(self)
    [self.sdk.audio.volumeSubject subscribeNext:^(id x) {
        @strongify(self)
        [self.wrapVolumeSubject sendNext:x];
    }];
}

- (RACSubject *)onKictOutRoom {
    return [self.sdk.audio onKickOutRoom];
}

#pragma mark - Polling Config

- (void)initConfigPollingService {
    self.pollingService = [SNConfigPollingService new];
    self.pollingService.targetRoomId = self.configModel.roomId;
    @weakify(self)
    self.pollingService.onGetConfig = ^(SRSyncConfigModel * _Nullable newValue, NSError * _Nullable error) {
        if (!newValue) {
            SN_LOG_LOCAL(@"Sona Logan: switch config is nil");
            return;
        }
        @strongify(self)
        SNMsgSwitchModel *model = [SNMsgSwitchModel new];
        model.supplier = newValue.streamConfig.supplier;
        model.roomId = newValue.roomId;
        model.pullMode = newValue.streamConfig.pullMode;
        model.streamUrl = newValue.streamConfig.streamUrl;
        model.bitrate = newValue.streamConfig.bitrate;
        model.streamId = newValue.streamConfig.streamId;
        [self handleSwitchMsgWithModel:model];
    };
    NSMutableArray *needPollingEvents = @[].mutableCopy;
    if (self.sdk.audio.onPullStreamFail) {
        [needPollingEvents addObject:self.sdk.audio.onPullStreamFail];
    }
    if (self.sdk.audio.onNeedCheckConfig) {
        [needPollingEvents addObject:self.sdk.audio.onNeedCheckConfig];
    }
    if (needPollingEvents.count > 0) {
        [[RACSubject merge:needPollingEvents] subscribeNext:^(id x) {
            [self.pollingService startPolling:false];
        }];
    }
}

- (void)stopConfigPolling {
    self.hasStopPolling = true;
    [self.pollingService stopPolling];
}

#pragma mark - A-V Switch(Mixed)

- (RACSignal *)switchToVideo:(CGSize)size {
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        return [RACSignal return:@0];
    }
    return [[[SRStreamMixVideoRequestSignal mixedVideo:true
                                                roomId:self.configModel.roomId
                                                  size:size] flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
        return [RACSignal return:@1];
    }] catch:^RACSignal *(NSError *error) {
        return [RACSignal error:error];
    }];
}

- (RACSignal *)switchToAudio {
    return [[[SRStreamMixVideoRequestSignal mixedVideo:false
                                                roomId:self.configModel.roomId
                                                  size:CGSizeZero] flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
        return [RACSignal return:@1];
    }] catch:^RACSignal *(NSError *error) {
        return [RACSignal error:error];
    }];
}

#pragma mark - Reboot Service

- (void)initRebootService {
    self.rebootService = [SRRebootServiceManager new];
    @weakify(self)
    self.rebootService.audioPrepReboot.onRebootAction = ^(id  _Nonnull processor) {
        @strongify(self)
        [self.sdk.audio setAudioPrep:processor];
    };
}

#pragma mark - Audio Stream Event

- (RACSubject *)onPullStreamFail {
    return [self.sdk.audio onPullStreamFail];
}

- (RACSubject *)onPullStreamSuccess {
    return [self.sdk.audio onPullStreamSuccess];
}

- (RACSubject *)onPublishStreamFail {
    return [self.sdk.audio onPublishStreamFail];
}

- (RACSubject *)onPublishStreamSuccess {
    return [self.sdk.audio onPublishStreamSuccess];
}

#pragma mark - SEI

- (void)sendSEIMessageWithDataDict:(NSDictionary *)dataDict {
    return [self.sdk.audio sendSEIMessageWithDataDict:dataDict];
}

#pragma mark - Properties

- (RACSubject *)configSubject {
    if (!_configSubject) {
        _configSubject = [RACSubject new];
    }
    return _configSubject;
}

- (RACSubject *)wrapVoiceApertureSubject {
    if (!_wrapVoiceApertureSubject) {
        _wrapVoiceApertureSubject = [RACSubject subject];
        [self subscribeInnerVoiceAperture];
    }
    return _wrapVoiceApertureSubject;
}

- (RACSubject *)wrapVolumeSubject {
    if (!_wrapVolumeSubject) {
        _wrapVolumeSubject = [RACSubject subject];
        [self subscribeInnerVolumeSubject];
    }
    return _wrapVolumeSubject;
}

- (void)setDeviceMode:(SRDeviceMode)mode {
    [self.sdk.audio setDeviceMode:mode];
}

@end
