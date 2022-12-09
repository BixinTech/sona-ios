//
//  SNZGMediaPlayer.m
//  SonaAudio
//
//  Created by Ju Liaoyuan on 2021/4/6.
//

#import "SNZGMediaPlayer.h"
#import <ReactiveObjC/RACSignal.h>
#import "SNZGAudio.h"
#import "SNAudio.h"
#import "SNMacros.h"
#import "SNZGAuxPlayer.h"
#import "SNZGLocalPlayer.h"

@interface SNZGMediaPlayer ()

@property (nonatomic, strong) SNZGAuxPlayer *auxPlayer;

@property (nonatomic, strong) SNZGLocalPlayer *localPlayer;

@property (nonatomic, strong) SNZGPCMPlayer *pcmPlayer;

@end

@implementation SNZGMediaPlayer

#pragma mark - init player

- (id<SNMediaPlayer>)localPlayer {
    if (!_localPlayer) {
        _localPlayer = [SNZGLocalPlayer new];
        _localPlayer.proxy = self.proxy;
        _localPlayer.zegoApi = self.zegoApi;
    }
    return _localPlayer;
}

- (id<SNMediaPlayer>)auxPlayer {
    if (!_auxPlayer) {
        _auxPlayer = [SNZGAuxPlayer new];
        _auxPlayer.proxy = self.proxy;
        _auxPlayer.zegoApi = self.zegoApi;
    }
    return _auxPlayer;
}

- (id<SNPCMPlayer>)pcmPlayer {
    if (!_pcmPlayer) {
        _pcmPlayer = [SNZGPCMPlayer new];
    }
    return _pcmPlayer;
}


#pragma mark - destory player

- (void)destroyAuxPlayer {
    [_auxPlayer destroy];
    _auxPlayer = nil;
}

- (void)destroyLocalPlayer {
    [_localPlayer destroy];
    _localPlayer = nil;
}

- (void)destroyPCMPlayer {
    [_pcmPlayer destroy];
    _pcmPlayer = nil;
}

- (void)destroyPlayer {
    [self destroyAuxPlayer];
    [self destroyLocalPlayer];
    [self destroyPCMPlayer];
}



@end
