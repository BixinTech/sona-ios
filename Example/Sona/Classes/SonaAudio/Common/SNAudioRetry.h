//
//  SNAudioRetry.h
//  SonaRoom
//
//  Created by Ju Liaoyuan on 2021/11/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SNAudio;

@interface SNAudioRetry : NSObject

- (instancetype)initWithAudio:(SNAudio *)audio;

/** 检查是否可以拉流重试，如果命中重试策略，内部会主动去重试拉流一次
 * @param streamId 流id
 * @param isMixed 是否是混流
 *
 * @return 是否在重试
 */
- (BOOL)checkAndRetryToPullStream:(NSString *)streamId isMixed:(BOOL)isMixed;

/** 检查是否可以推流重试，如果命中重试策略，内部会主动去重试推流一次
 * @param streamId 流id
 *
 * @return 是否在重试
 */
- (BOOL)retryToPublishStream:(NSString *)streamId;
    
@end

NS_ASSUME_NONNULL_END
