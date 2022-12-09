//
//  SNCopyrightedMediaPlayer.h
//  SonaRoom
//
//  Created by Ju Liaoyuan on 2022/1/6.
//

#import <Foundation/Foundation.h>
#import "SNMediaPlayer.h"

@class RACSubject;

NS_ASSUME_NONNULL_BEGIN

typedef NSString * SNCopyrightedMediaBitrate;

/**
 * 可选码率
 */
static SNCopyrightedMediaBitrate const SNCopyrightedMediaBitrate64   = @"audio/mi";
static SNCopyrightedMediaBitrate const SNCopyrightedMediaBitrate128  = @"audio/lo";
static SNCopyrightedMediaBitrate const SNCopyrightedMediaBitrate320  = @"audio/hi";

/**
 * 版权音乐播放器接口。主要针对需要播放版权音乐（无法获取到音乐的URL）的场景。
 * 如果需要播放网络音乐（可以获取到URL），直接使用 SNMediaPlayer 的功能即可。
 *
 * **NOTE: 由于版权原因，无法播放流媒体音乐，所以会需要先 download 本地，再进行播放，业务上要做相关的处理。**
 */
@protocol SNCopyrightedMediaPlayer <NSObject, SNMediaPlayer>

@required

/**
 * 播放版权音乐
 * @param musicId 音乐id
 * @param token 播放的token
 *
 * **NOTE: 该接口无码率设置，内部会使用默认码率（low）。**
 * 如果要设置单曲的码率，可以使用 `-playWithMusicId:token:bitrate:`。
 */
- (void)playWithMusicId:(NSString *)musicId token:(NSString *)token;

/**
 * 播放版权音乐，可以指定音乐的码率
 * @param musicId 音乐id
 * @param token 播放的token
 * @param bitrate 音乐的码率，可选值参考 SNCopyrightedMediaBitrate 常量。
 */
- (void)playWithMusicId:(NSString *)musicId token:(NSString *)token bitrate:(SNCopyrightedMediaBitrate __nullable)bitrate;

/**
 * 歌曲下载进度回调
 * @return 返回值为元组
 *
 * 1. 第一个元素为歌曲id，类型为
 * 2. 第二个元素为下载进度百分比，类型为 NSNumber(CGFloat)，值范围为 0 ~ 1
 * 3. 第三个元素为是否完成的标志位，类型为 NSNumber(BOOL)，0 代表未结束，1 代表下载完成
 */
- (RACSubject *)onLoadProgress;

/**
 * 播放错误回调
 * @return NSError 对象
 */
- (RACSubject *)onPlayError;

@optional

/**
 * 清除歌曲本地缓存
 */
- (void)clearCacheData;

/**
 * 设置最大缓冲歌曲数
 */
- (void)setMaxCacheMusicCount:(int)count;

/**
 * 检查本地资源是否存在
 *
 * @param musicId 音乐id
 * @param bitrate 音乐资源码率
 * @return true: 已缓存； false：未缓存
 */
- (BOOL)checkMusicCached:(NSString *)musicId bitrate:(SNCopyrightedMediaBitrate)bitrate;

/** 设置播放进度回调频率(Zego 房间生效)
 * @param interval 回调频率，单位 ms，默认 1000ms
 */
- (void)setProgressInterval:(NSInteger)interval;

@end

NS_ASSUME_NONNULL_END
