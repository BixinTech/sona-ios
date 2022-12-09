//
//  SNAudioPreprocessProxy.h
//  SonaAudio
//
//  Created by Ju Liaoyuan on 2021/9/26.
//

#import <Foundation/Foundation.h>
#import "SNAudioPrepProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@protocol SNAudioPreprocessProxy <NSObject>

@required

/**
 * 开启音频预处理
 */
- (void)enableAudioPreprocess:(id<SNAudioPrepProtocol>)processor;

/**
 * 关闭指定的音频预处理
 */
- (void)disableAudioPreprocess:(id<SNAudioPrepProtocol>)processor;

/**
 * 关闭音频预处理
 */
- (void)closeAudioPreprocess;

@end

NS_ASSUME_NONNULL_END
