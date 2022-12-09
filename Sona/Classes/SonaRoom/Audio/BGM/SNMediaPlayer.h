
//
//  SNMediaPlayer.h
//  SonaAudio
//
//  Created by Ju Liaoyuan on 2021/4/6.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ReactiveObjC/RACSignal.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SNPlayerAudioStreamIndex) {
    /// 原唱
    SNPlayerAudioStreamIndexOri = 0,
    /// 伴奏
    SNPlayerAudioStreamIndexBgm = 1,
};

/**
 * 多媒体播放器, 支持aac, mp3, m4a, mp4
 */
@protocol SNMediaPlayer <NSObject>

/**
* 播放
* @param path 路径
* @param isRepeat 是否重复播放
* @return 开始播放回调
*/
- (RACSignal *)playWithPath:(NSString *)path isRepeat:(BOOL)isRepeat;

/**
* 播放视频
* @param path 路径
* @param isRepeat 是否重复播放
* @param view 用于展示视频的 view
* @return 开始播放回调
*/
- (RACSignal *)playVideoWithPath:(NSString *)path isRepeat:(BOOL)isRepeat inView:(nullable UIView *)view;

/**
 * 停止播放
 * @return 完成回调
 */
- (RACSignal *)stop;

/**
 * 暂停播放
 * @return 完成回调
 */
- (RACSignal *)pause;

/**
 * 继续播放
 * @return 完成回调
 */
- (RACSignal *)resume;

/**
 * 设置音量, 音量大小，100为正常音量，取值范围为0 - 200；默认值：100
 */
- (void)setVolume:(NSInteger)volume;

/**
  * 获取音量大小，范围为0-200
 */
- (NSInteger)volume;

/**
 * 获取当前长度
 * @return bgm 时长，单位毫秒
 */
- (RACSignal *)duration;

/**
 * 获取指定路径长度
 * @return bgm 时长，单位毫秒
 */
- (RACSignal *)duration:(NSString *)path;

/**
 * 设置当前播放位置, 单位毫秒
 * @return 完成回调，包含的值为seek的最终值(会和position有偏差)
 */
- (RACSignal *)seekTo:(NSInteger)position;

/**
 * 播放进度回调，回调的频率默认是 1000ms。
 * 注意：回调不在主线程，涉及到UI请自行切换到主线程
 */
- (RACSubject *)onPlayProgress;

/**
 * 播放开始
 */
- (RACSubject *)onPlayBegin;

/**
 * 播放结束
 */
- (RACSubject *)onPlayEnd;

/**
 * 开始缓冲回调
 */
- (RACSubject *)onBufferBegin;
/**
 * 结束缓冲回调
 */
- (RACSubject *)onBufferEnd;

/**
 * 播放失败回调
 */
- (RACSubject *)onPlayError;

/**
 * 播放器标识
 */
- (NSInteger)playerIdentifier;

/**
 * 设置(更新)播放器播放的 view
 */
- (void)setView:(nullable UIView *)view;

/**
 * 获取音轨数量
 */
- (NSInteger)getAudioStreamCount;

/** 设置播放音轨
 @param index 音轨下标，@see SNPlayerAudioStreamIndex，
        default is SNPlayerAudioStreamIndexOri
 */
- (BOOL)setAudioStream:(SNPlayerAudioStreamIndex)index;

/**
 * 销毁播放器
 */
- (void)destroy;


@end

NS_ASSUME_NONNULL_END
