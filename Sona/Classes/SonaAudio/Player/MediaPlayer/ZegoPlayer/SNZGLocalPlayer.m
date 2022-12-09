//
//  SNZGLocalPlayer.m
//  SonaAudio
//
//  Created by Ju Liaoyuan on 2021/4/9.
//

#import "SNZGLocalPlayer.h"
#import "SNLoggerHelper.h"

@interface SNZGLocalPlayer ()

@property (nonatomic, strong) ZegoMediaPlayer *localPlayer;

@end

@implementation SNZGLocalPlayer

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configPlayer];
    }
    return self;
}

- (void)configPlayer {
    self.localPlayer = [[ZegoMediaPlayer alloc] initWithPlayerType:MediaPlayerTypePlayer playerIndex:ZegoMediaPlayerIndexThird];
    [self.localPlayer setVolume:100];
    [self.localPlayer requireHWDecoder];
    [self.localPlayer setProcessInterval:1000];
    [self.localPlayer enableAccurateSeek:true];
    [self.localPlayer setEventWithIndexDelegate:self];
}

- (ZegoMediaPlayer *)mediaPlayer {
    return self.localPlayer;
}

- (NSInteger)playerIdentifier {
    return ZegoMediaPlayerIndexThird;
}

- (NSString *)genLog:(NSString *)event {
    // 添加前缀
    return [NSString stringWithFormat:@"Zego Play Audio %@ (Local)", event];
}

- (void)destroy {
    [super destroy];
    SN_LOG_LOCAL(@"Sona Logan: %@, destroy", self);
    [self.localPlayer setEventWithIndexDelegate:nil];
    [self.localPlayer uninit];
    self.localPlayer = nil;
}

- (void)dealloc {
    SN_LOG_LOCAL(@"Sona Logan: %@, %s", self, __func__);
}

@end
