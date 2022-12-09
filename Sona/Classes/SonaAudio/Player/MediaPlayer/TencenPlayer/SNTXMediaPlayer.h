//
//  SNTXMediaPlayer.h
//  SonaAudio
//
//  Created by Ju Liaoyuan on 2022/3/3.
//

#import <Foundation/Foundation.h>
#import "SNMediaPlayer.h"
#import "SNCopyrightedMediaPlayer.h"

NS_ASSUME_NONNULL_BEGIN

@class TXAudioEffectManager;

@interface SNTXMediaPlayer : NSObject

@property (nonatomic, weak) TXAudioEffectManager *manager;

/**
 * 本地播放器，不会将媒声音混入流中
 */
- (id<SNMediaPlayer>)localPlayer;

/**
 * 本地播放器，播放时将媒体声音混入流中
 */
- (id<SNMediaPlayer>)auxPlayer;

/**
 * 销毁 aux player
 */
- (void)destroyAuxPlayer;

/**
 * 销毁 local player
 */
- (void)destroyLocalPlayer;


/**
 * 销毁所有的 player
 */
- (void)destroyPlayer;

@end

NS_ASSUME_NONNULL_END
