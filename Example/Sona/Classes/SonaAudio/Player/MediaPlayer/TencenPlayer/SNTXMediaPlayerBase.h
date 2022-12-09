//
//  SNTXMediaPlayerBase.h
//  SonaAudio
//
//  Created by Ju Liaoyuan on 2022/3/3.
//

#import <Foundation/Foundation.h>
#import "SNMediaPlayer.h"

@class TXAudioEffectManager;

NS_ASSUME_NONNULL_BEGIN

@interface SNTXMediaPlayerBase : NSObject<SNMediaPlayer>

- (void)setPlayerManager:(TXAudioEffectManager *)manager;

- (BOOL)isPublish;

@end

NS_ASSUME_NONNULL_END
