//
//  SNAudioMix.h
//  SonaAudio
//
//  Created by Ju Liaoyuan on 2022/1/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SNAudioMix : NSObject

//void AudioMix::Process(short* micBuffer, short* bgmBuffer, short* accomBuffer, short** mixOutBuffer, short** mixBgmAccomOutBuffer)

/**
 * 0 ~ 100
 * default is 100
 */
@property (nonatomic, assign) NSInteger micVolume;

/**
 * 0 ~ 100
 * default is 100
 */
@property (nonatomic, assign) NSInteger bgmVolume;

- (instancetype)initWithSamples:(NSInteger)samples NS_DESIGNATED_INITIALIZER;

/**
 * @param micBuf mic的PCM数据
 * @param bgmBuf bgm的PCM数据
 * @param mixedOutBuf 混音后的PCM数据，内部会回传处理好的数组地址，外界无需关心内存管理
 */
- (void)processMix:(short *)micBuf bgmBuffer:(short *)bgmBuf mixedOutBuffer:(short **)mixedOutBuf;


@end

NS_ASSUME_NONNULL_END
