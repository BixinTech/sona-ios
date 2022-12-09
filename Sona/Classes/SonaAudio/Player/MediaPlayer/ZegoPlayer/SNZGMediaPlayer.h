//
//  SNZGMediaPlayer.h
//  SonaAudio
//
//  Created by Ju Liaoyuan on 2021/4/6.
//

#import <Foundation/Foundation.h>
#import <ZegoLiveRoom/zego-api-mediaplayer-oc.h>
#import "SNZGAuxPlayer.h"
#import "SNMediaPlayer.h"
#import "SNZGPCMPlayer.h"

@class SNZGAudio;

NS_ASSUME_NONNULL_BEGIN

@interface SNZGMediaPlayer : NSObject

@property (nonatomic, weak) SNZGAudio *proxy;

@property (nonatomic, weak) ZegoLiveRoomApi *zegoApi;

/**
 * 本地播放器，不会将媒声音混入流中
 */
- (id<SNMediaPlayer>)localPlayer;

/**
 * 本地播放器，播放时将媒体声音混入流中
 */
- (id<SNMediaPlayer>)auxPlayer;

/**
 * PCM 本地播放器
 */
- (id<SNPCMPlayer>)pcmPlayer;

/**
 * 销毁 aux player
 */
- (void)destroyAuxPlayer;

/**
 * 销毁 local player
 */
- (void)destroyLocalPlayer;

/**
 * 销毁 pcm player
 */
- (void)destroyPCMPlayer;

/**
 * 销毁所有的 player
 */
- (void)destroyPlayer;

@end

NS_ASSUME_NONNULL_END
