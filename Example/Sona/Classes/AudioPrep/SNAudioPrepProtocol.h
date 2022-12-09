//
//  SNAudioPrepProtocol.h
//
//  Created by Ju Liaoyuan on 2021/4/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SNAudioPrepProtocol <NSObject>

@required
/**
 *  PCM 数据格式，调用方可以在该回调用拿到格式信息，用来初始化自己的音频处理单元
 *  channels: 通道数
 *  sampleRate: 采样率
 *  presentationTime: 帧时长
 */
- (void)audioFrameFormat:(int)channels sampleRate:(int)sampleRate presentationTime:(float)presentationTime;

/**
 * 预处理回调
 * inFrame: 输入帧
 * outFrame: 处理后的输出帧
 * length: 输入帧的长度
 */
- (void)audioPreprocessWithInFrame:(unsigned char *)inFrame
                          outFrame:(unsigned char *)outFrame
                            length:(int)inFrameLength;

@end

NS_ASSUME_NONNULL_END
