//
//  SNPCMPlayer.h
//  SonaRoom
//
//  Created by Ju Liaoyuan on 2021/12/24.
//

#import <Foundation/Foundation.h>
#import "SNPCMPlayer.h"
#import "SNPCMFormat.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SNPCMPlayerProvider <NSObject>

/**
 * Sona 会通过该接口，以固定频率来问 provider 要 PCM 数据。
 * 该接口的回调频率非常快。所以不要在里面做耗时操作。否则会影响正常的声音。
 *
 * data: pcm 容器，内存管理由 Sona 内部负责， 外界无需关心，只负责往里面写数据即可
 * length: 预期的 pcm 数据长度，与 data 容器大小对应。*请不要写入超过 length 长度的数据*。
 *       如果写入数据小于预期长度，外界可以修改 length 的值来告诉 Sona 实际的长度。
 * NOTE: 如果 length 为 0，Sona 内部不会处理 data 中的数据，直接丢弃。
 */
- (void)onPlayPCMData:(unsigned char *)data length:(int *)length;

@end

@protocol SNPCMPlayer <NSObject>

/**
 * PCM 提供方
 */
@property (nonatomic, weak) id<SNPCMPlayerProvider> provider;

@required

/**
 * 开始播放
 */
- (void)startPlay;

/**
 * 停止播放
 */
- (void)stopPlay;

/**
 * 通过该接口，可以获取当前房间内的PCM数据格式
 */
- (SNPCMFormat *)getPCMFormat;

/**
 * 设置播放音量，默认 30
 */
- (void)setVolume:(int)volume;

/**
 * 获取播放音量
 */
- (int)volume;

/**
 * 销毁播放器，再次使用时需要重新初始化
 */
- (void)destroy;

@end

NS_ASSUME_NONNULL_END
