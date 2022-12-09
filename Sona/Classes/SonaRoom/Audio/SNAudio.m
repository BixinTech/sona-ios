//
//  SNAudio.m
//  SonaSDK
//
//  Created by Insomnia on 2019/12/4.
//

#import "SNAudio.h"
#import "SNMacros.h"
#import "SNMediaPlayer.h"
#import "SNLoggerHelper.h"

#if __has_include("SonaAudio.h")
#import "SonaAudio.h"
#endif


@interface SNAudio ()

@property(nonatomic, strong, readwrite) SNAudio *driver;

@property (nonatomic, strong) id<SNMediaPlayer> localPlayer;

@property (nonatomic, strong) id<SNMediaPlayer> auxPlayer;

@property(nonatomic, copy) NSString *supplier;

@property (nonatomic, assign) BOOL micEnabled;

@property (nonatomic, strong) RACSubject *onPullStreamTempFail;

@property (nonatomic, strong) RACSubject *onPublishStreamFail;

@property (nonatomic, strong) RACSubject *onPublishStreamTempFail;
@end

@implementation SNAudio

- (instancetype)initWithConfigModel:(SNConfigModel *)configModel {
    self = [SNAudio new];
    if (self) {
        self.micEnabled = true;
        [self initDriverWithModel:configModel];
    }
    return self;
}

- (void)dealloc {
    if (_driver) {
        _driver = nil;
    }
}

- (void)initDriverWithModel:(SNConfigModel *)model {
    self.supplier = model.productConfig.streamConfig.supplier;
    model.micEnabled = self.micEnabled;
    #ifdef SONAAUDIO
    if ([model.productConfig.streamConfig.supplier isEqualToString:SN_STREAM_SUPPLIER_ZEGO]) {
        self.driver = [[SNZGAudio alloc] initWithConfigModel:model];
    } else if ([model.productConfig.streamConfig.supplier isEqualToString:SN_STREAM_SUPPLIER_TENCENT]) {
        self.driver = [[SNTXAudio alloc] initWithConfigModel:model];
    } else {
        SN_LOG_LOCAL(@"Sona Logan: init driver fail, supplier %@ not support", self.supplier);
    }
    #endif
}

- (RACSignal *)updateConfigModel:(SNConfigModel *)configModel {
    @weakify(self);
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        if (![self.supplier isEqualToString:configModel.productConfig.streamConfig.supplier]) {
            [self initDriverWithModel:configModel];
        }
        [subscriber sendNext:nil];
        [subscriber sendCompleted];
        return nil;
    }] flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
        @strongify(self);
        return [self.driver updateConfigModel:configModel];
    }];
}

- (BOOL)beenEntered {
    return [self.driver beenEntered];
}

- (void)setAudioPrep:(id<SNAudioPrepProtocol>)processor {
    if (![processor conformsToProtocol:@protocol(SNAudioPrepProtocol)]) {
        return;
    }
    [self.driver setAudioPrep:processor];
}

- (void)removeAudioPrep:(id<SNAudioPrepProtocol>)processor {
    [self.driver removeAudioPrep:processor];
}

- (RACSignal *)enter {
    return [self.driver enter];
}

- (RACSignal *)leave {
    return [self.driver leave];
}

- (RACSignal *)startPublishWithId:(NSString *)idStr {
    return [self.driver startPublishWithId:idStr];
}

- (RACSignal *)stopPublish {
    return [self.driver stopPublish];
}

- (RACSignal *)startPullAllId {
    return [self.driver startPullAllId];
}

- (RACSignal *)startPullWithId:(NSString *)idStr {
    return [self.driver startPullWithId:idStr];
}

- (RACSignal *)startPullWithIdArr:(NSArray <NSString *> *)idArr {
    return [self.driver startPullWithIdArr:idArr];
}

- (RACSignal *)stopPullWithId:(NSString *)idStr {
    return [self.driver stopPullWithId:idStr];
}

- (RACSignal *)stopPullWithIdArr:(NSArray<NSString *> *)idArr {
    return [self.driver stopPullWithIdArr:idArr];
}

- (RACSignal *)stopPullAllId {
    return [self.driver stopPullAllId];
}

- (RACSignal *)enableMic {
    return [[[self.driver enableMic] flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
        self.micEnabled = true;
        return [RACSignal return:value];
    }] catch:^RACSignal *(NSError *error) {
        return [RACSignal return:error];
    }];
}

- (RACSignal *)unableMic {
    return [[[self.driver unableMic] flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
        self.micEnabled = false;
        return [RACSignal return:value];
    }] catch:^RACSignal *(NSError *error) {
        return [RACSignal return:error];
    }];
}

- (RACSignal *)enableSpeaker {
    return [self.driver enableSpeaker];
}

- (RACSignal *)unableSpeaker {
    return [self.driver unableSpeaker];
}

- (RACSignal *)muteWithId:(NSString *)idStr {
    return [self.driver muteWithId:idStr];
}

- (RACSignal *)unMuteWithId:(NSString *)idStr {
    return [self.driver unMuteWithId:idStr];
}

- (RACSignal *)muteWithIdArr:(NSArray<NSString *> *)idArr {
    return [self.driver muteWithIdArr:idArr];
}

- (RACSignal *)unMuteWithIdArr:(NSArray<NSString *> *)idArr {
    return [self.driver unMuteWithIdArr:idArr];
}

- (BOOL)isPullingWithId:(NSString *)idStr {
    return [self.driver isPullingWithId:idStr];
}

- (NSSet <NSString *> *)pullingAccIdSet {
    return [self.driver pullingAccIdSet];
}

- (NSSet <NSString *> *)allStreamSet {
    return [self.driver allStreamSet];
}

- (RACSignal *)isPullingSignal {
    return [self.driver isPullingSignal];
}

- (RACSignal *)isPublishingSignal {
    return [self.driver isPublishingSignal];
}

- (BOOL)isPublishing {
    return [self.driver isPublishing];
}

- (NSInteger)getAudioStreamCount {
    return [self.driver getAudioStreamCount];
}

- (BOOL)setAudioStream:(SNPlayerAudioStreamIndex)index {
    return [self.driver setAudioStream:index];
}

- (RACSignal *)uploadSDKLog {
    return [self.driver uploadSDKLog];
}

- (RACSubject *)volumeSubject {
    return [self.driver volumeSubject];
}

- (RACSubject *)disconnectSubject {
    return [self.driver disconnectSubject];
}
- (RACSubject *)reconnectSubject {
    return [self.driver reconnectSubject];
}

- (RACSignal *)voiceApertureSubject {
    return [self.driver voiceApertureSubject];
}

- (RACSignal *)reEnter {
    return [self.driver reEnter];
}

- (RACSubject *)publishEventCallback {
    return [self.driver publishEventCallback];
}

- (SNSDKPluginType)pluginType {
    return SNSDKPluginTypeAudio;
}

- (id<SNMediaPlayer>)localPlayer {
    return self.driver.localPlayer;
}

- (id<SNMediaPlayer>)auxPlayer {
    return self.driver.auxPlayer;
}

- (id<SNPCMPlayer>)pcmPlayer {
    return self.driver.pcmPlayer;
}

- (id<SNCopyrightedMediaPlayer>)musicPlayer {
    return self.driver.musicPlayer;
}

- (BOOL)setReverbMode:(SNVoiceReverbMode)mode {
    return [self.driver setReverbMode:mode];
}

- (void)setStreamRenderView:(UIView *)view {
    [self.driver setStreamRenderView:view];
}

- (RACSubject *)videoFirstRenderCallback {
    return [self.driver videoFirstRenderCallback];
}

- (void)setCaptureVolume:(NSInteger)volume {
    [self.driver setCaptureVolume:volume];
}

- (NSInteger)getCaptureVolume {
    return [self.driver getCaptureVolume];
}

- (BOOL)enableLoopback {
    return [self.driver enableLoopback];
}

- (BOOL)disableLoopback {
    return [self.driver disableLoopback];
}

- (void)setLoopbackVolume:(NSInteger)volume {
    return [self.driver setLoopbackVolume:volume];
}

- (RACSubject *)onReceiveMediaSideInfo {
    return [self.driver onReceiveMediaSideInfo];
}

- (RACSubject *)onPullStreamFail {
    return [self.driver onPullStreamFail];
}

- (RACSubject *)onPullStreamSuccess {
    return [self.driver onPullStreamSuccess];
}

- (RACSubject *)onPublishStreamFail {
    return [self.driver onPublishStreamFail];
}

- (RACSubject *)onPublishStreamSuccess {
    return [self.driver onPublishStreamSuccess];
}

- (RACSubject *)onKickOutRoom {
    return [self.driver onKickOutRoom];
}

- (RACSubject *)onNeedCheckConfig {
    return [self.driver onNeedCheckConfig];
}


- (void)setDeviceMode:(SRDeviceMode)mode {
    [self.driver setDeviceMode:mode];
}

- (void)sendSEIMessageWithDataDict:(NSDictionary *)dataDict {
    return [self.driver sendSEIMessageWithDataDict:dataDict];
}

@end
