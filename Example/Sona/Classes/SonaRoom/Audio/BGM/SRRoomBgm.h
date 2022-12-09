//
//  SRBgm.h
//  SonaRoom
//
//  Created by Insomnia on 2020/3/13.
//

#import <Foundation/Foundation.h>
#import "ReactiveCocoa.h"
#import "SNMediaPlayer.h"
#import "SNPCMPlayer.h"
#import "SNCopyrightedMediaPlayer.h"

@class SNConfigModel;

NS_ASSUME_NONNULL_BEGIN

@interface SRRoomBgm : NSObject

- (instancetype)initWithTuple:(RACTuple *)tuple;

/**
 * 本地播放器，不会将播放的数据混入流中
 */
@property (nonatomic, strong, readonly) id<SNMediaPlayer> localPlayer;

/**
 * 混流播放器，播放的同时，会将数据推到流中
 */
@property (nonatomic, strong, readonly) id<SNMediaPlayer> auxPlayer;

@property (nonatomic, strong, readonly) id<SNPCMPlayer> pcmPlayer;

/**
 * 版权音乐播放器。详情见 `SNCopyrightedMediaPlayer`
 */
@property (nonatomic, strong, readonly) id<SNCopyrightedMediaPlayer> musicPlayer;

/**
 * 更新配置
 */
- (void)updateConfigWithModel:(SNConfigModel *)model;

@end

NS_ASSUME_NONNULL_END
