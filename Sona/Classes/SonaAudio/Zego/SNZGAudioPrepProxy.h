//
//  SNZGAudioPrepProxy.h
//  SonaAudio
//
//  Created by Ju Liaoyuan on 2021/4/16.
//

#import <Foundation/Foundation.h>
#import "SNAudioPrepProtocol.h"
#import "SNAudioPreprocessProxy.h"

@class ZegoLiveRoomApi;

NS_ASSUME_NONNULL_BEGIN

@interface SNZGAudioPrepProxy : NSObject<SNAudioPreprocessProxy>

- (instancetype)initWithZegoApi:(ZegoLiveRoomApi *)api;

@end

NS_ASSUME_NONNULL_END
