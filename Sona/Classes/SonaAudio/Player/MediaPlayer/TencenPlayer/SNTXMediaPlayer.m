//
//  SNTXMediaPlayer.m
//  SonaAudio
//
//  Created by Ju Liaoyuan on 2022/3/3.
//

#import "SNTXMediaPlayer.h"
#import "SNTXAuxPlayer.h"
#import "SNTXLocalPlayer.h"

@interface SNTXMediaPlayer ()

@property (nonatomic, strong) SNTXAuxPlayer *auxPlayer;

@property (nonatomic, strong) SNTXLocalPlayer *localPlayer;

@end

@implementation SNTXMediaPlayer

- (id<SNMediaPlayer>)auxPlayer {
    if (!_auxPlayer) {
        _auxPlayer = [SNTXAuxPlayer new];
        [_auxPlayer setPlayerManager:self.manager];
    }
    return _auxPlayer;
}

- (id<SNMediaPlayer>)localPlayer {
    if (!_localPlayer) {
        _localPlayer = [SNTXLocalPlayer new];
        [_localPlayer setPlayerManager:self.manager];
    }
    return _localPlayer;
}

- (void)destroyPlayer {
    [self destroyAuxPlayer];
    [self destroyLocalPlayer];
}

- (void)destroyAuxPlayer {
    [_auxPlayer destroy];
}

- (void)destroyLocalPlayer {
    [_localPlayer destroy];
}

@end
