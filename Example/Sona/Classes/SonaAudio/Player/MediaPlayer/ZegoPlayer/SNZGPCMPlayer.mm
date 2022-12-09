//
//  SNZGPCMPlayer.m
//  SonaAudio
//
//  Created by Ju Liaoyuan on 2021/12/20.
//

#import "SNZGPCMPlayer.h"
#import <ZegoLiveRoom/ZegoLiveRoomApi.h>
#import <ZegoLiveRoom/zego-api-mediaplayer-oc.h>

#import "SNResourceManager.h"
#import <thread>
#import "SNLoggerHelper.h"

#define PCM_SAMPLE_RATE 44100
#define PCM_CHANNELS 2
#define PCM_BIT_DEPTH 16

@interface SNZGPCMPlayer ()<ZegoMediaPlayerEventWithIndexDelegate, ZegoMediaPlayerAudioPlayDelegate> {
    std::mutex _captureLock;
}

@property (nonatomic, strong) ZegoMediaPlayer *player;

@property (nonatomic, strong) SNPCMFormat *pcmFormat;

@property (atomic, assign) bool hasStop;

@property (nonatomic, assign) NSInteger lastDataLength;

@end

@implementation SNZGPCMPlayer

@synthesize provider = _provider;

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configPlayer];
    }
    return self;
}

- (void)configPlayer {
    
    self.player = [[ZegoMediaPlayer alloc] initWithPlayerType:MediaPlayerTypePlayer playerIndex:ZegoMediaPlayerIndexFourth];
    [self.player setLoopCount:-1];
    [self.player setAudioPlayDelegate:self];
    [self.player setVolume:30];
    [self.player requireHWDecoder];
    [self.player setProcessInterval:1000];
    [self.player enableAccurateSeek:true];
    [self.player setEventWithIndexDelegate:self];
    
    self.pcmFormat = [[SNPCMFormat alloc] initWithSampleRate:PCM_SAMPLE_RATE
                                                    bitDepth:PCM_BIT_DEPTH
                                                    channels:PCM_CHANNELS];
}

- (void)startPlay {
    if (!_provider || ![_provider respondsToSelector:@selector(onPlayPCMData:length:)]) {
        NSAssert(NO, @"pcm provider is invalid");
        SN_LOG_LOCAL(@"Sona Logan: pcm provider is invalid");
        return;
    }
    NSString *slient = [SNResourceManager pathForResource:@"slient" type:@"wav"];
    if (slient) {
        [self.player start:slient startPosition:0];
        self.hasStop = false;
    }
}

- (void)stopPlay {
    self.hasStop = true;
    [self.player stop];
}

- (int)volume {
    return self.player.getPlayVolume;
}

- (void)setVolume:(int)volume {
    [self.player setPlayVolume:volume];
}

- (SNPCMFormat *)getPCMFormat {
    return _pcmFormat;
}

- (void)setProvider:(id<SNPCMPlayerProvider>)provider {
    _provider = provider;
    SN_LOG_LOCAL(@"Sona Logan: pcm provider:%@", provider);
}

- (void)onPlayAudioData:(unsigned char *const)data length:(int)length sample_rate:(int)sample_rate channels:(int)channels bit_depth:(int)bit_depth playerIndex:(ZegoMediaPlayerIndex)index {
    std::lock_guard<std::mutex> lg(_captureLock);
    // 已经停止，或者 provider 不存在，直接 return
    if (self.hasStop || !_provider || index != ZegoMediaPlayerIndexFourth) {
        return;
    }
    int expectLength = length;
    [_provider onPlayPCMData:data length:&expectLength];
}

- (void)destroy {
    std::lock_guard<std::mutex> lg(_captureLock);
    SN_LOG_LOCAL(@"Sona Logan: %@, destroy", self);
    _provider = nil;
    [self stopPlay];
    [self.player setEventWithIndexDelegate:nil];
    [self.player uninit];
    self.player = nil;
}

@end
