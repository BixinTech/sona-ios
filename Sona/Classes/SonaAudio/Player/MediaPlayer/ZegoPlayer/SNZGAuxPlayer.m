//
//  SNZGAuxPlayer.m
//  SonaAudio
//
//  Created by Ju Liaoyuan on 2021/4/6.
//

#import "SNZGAuxPlayer.h"
#import "SNLoggerHelper.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "SNZGVideoCaptureFactory.h"

@interface SNZGAuxPlayer ()<SNZGVideoCaptureFactoryDelegate>

@property (nonatomic, strong) ZegoMediaPlayer *auxPlayer;

@property (nonatomic, strong) SNZGVideoCaptureFactory *videoCapture;

@property (atomic, assign, getter=isEnableCapture) BOOL enableCapture;

@end

@implementation SNZGAuxPlayer

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configPlayer];
    }
    return self;
}

- (void)configPlayer {
    self.auxPlayer = [[ZegoMediaPlayer alloc] initWithPlayerType:MediaPlayerTypeAux playerIndex:ZegoMediaPlayerIndexSecond];
    [self.auxPlayer setVolume:100];
    [self.auxPlayer requireHWDecoder];
    [self.auxPlayer setProcessInterval:1000];
    [self.auxPlayer enableAccurateSeek:true];
    [self.auxPlayer setViewMode:ZegoVideoViewModeScaleAspectFit];
    [self.auxPlayer setEventWithIndexDelegate:self];
}

- (SNZGVideoCaptureFactory *)videoCapture {
    if (!_videoCapture) {
        _videoCapture = [[SNZGVideoCaptureFactory alloc] init];
        _videoCapture.delegate = self;
    }
    return _videoCapture;
}

#pragma mark - override

- (ZegoMediaPlayer *)mediaPlayer {
    return self.auxPlayer;
}

- (NSInteger)playerIdentifier {
    return ZegoMediaPlayerIndexSecond;
}

- (RACSignal *)playVideoWithPath:(NSString *)path isRepeat:(BOOL)isRepeat inView:(UIView *)view {
    @weakify(self)
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        if (!self.isEnableCapture) {
            self.enableCapture = true;
            [ZegoExternalVideoCapture setVideoCaptureFactory:self.videoCapture
                                                channelIndex:ZEGOAPI_CHN_MAIN];
            [self.auxPlayer setVideoPlayWithIndexDelegate:self.videoCapture
                                                   format:ZegoMediaPlayerVideoPixelFormatBGRA32];
        }
        [self.zegoApi enableCamera:true];
        [subscriber sendNext:@1];
        [subscriber sendCompleted];
        return nil;
    }] flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
        return [super playVideoWithPath:path isRepeat:isRepeat inView:view];
    }];
}

- (RACSignal *)stop {
    @weakify(self)
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        [self.zegoApi enableCamera:false];
        [subscriber sendNext:@1];
        [subscriber sendCompleted];
        return nil;
    }] flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
        return [super stop];
    }];
}

- (NSString *)genLog:(NSString *)event {
    // 添加前缀
    return [NSString stringWithFormat:@"Zego Play Audio %@ (Aux)", event];
}

#pragma mark - SNZGVideoCaptureFactoryDelegate

- (void)onVideoSizeChanged:(CGSize)size {
    ZegoAVConfig *config = [ZegoAVConfig presetConfigOf:ZegoAVConfigPreset_High];
    config.videoEncodeResolution = size;
    config.bitrate = 1200*1000;
    config.fps = 15;
    BOOL result = [self.zegoApi setAVConfig:config];
    SN_LOG_LOCAL(@"Change AV Config:%@, result:%d", NSStringFromCGSize(size), result);
}

- (void)destroy {
    [super destroy];
    SN_LOG_LOCAL(@"Sona Logan: %@ destroy", self);
    [self.auxPlayer setEventWithIndexDelegate:nil];
    [self.auxPlayer uninit];
    self.auxPlayer = nil;
}

- (void)dealloc {
    SN_LOG_LOCAL(@"Sona Logan: %@, %s", self, __func__);
}


@end
