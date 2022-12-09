//
//  SNZGMediaPlayerBase.h
//  SonaAudio
//
//  Created by Ju Liaoyuan on 2021/4/9.
//

#import <Foundation/Foundation.h>
#import <ZegoLiveRoom/ZegoLiveRoomApi.h>
#import <ZegoLiveRoom/zego-api-mediaplayer-oc.h>
#import "SNMediaPlayer.h"
#import "SNZGAudio.h"

NS_ASSUME_NONNULL_BEGIN

@interface SNZGMediaPlayerBase : NSObject<SNMediaPlayer, ZegoMediaPlayerEventWithIndexDelegate>

@property (nonatomic, weak) SNZGAudio *proxy;

@property (nonatomic, weak) ZegoLiveRoomApi *zegoApi;

@property (nonatomic, strong) ZegoMediaPlayer *mediaPlayer;

- (NSString *)genLog:(NSString *)event;

@end

NS_ASSUME_NONNULL_END
