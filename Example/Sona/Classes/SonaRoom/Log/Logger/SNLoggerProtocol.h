//
//  SNLoggerProtocol.h
//  SonaRoom
//
//  Created by Ju Liaoyuan on 2022/1/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SNLoggerProtocol <NSObject>

/**
 * @param content 日志内容，具体类型要求由各个日志系统自行定义并解析
 * @param ext 扩展字段，统一为字典类型
 */
- (void)logWithContent:(NSString *)content ext:(NSDictionary *)ext;

+ (NSString *)sceneKey;

@end

NS_ASSUME_NONNULL_END
