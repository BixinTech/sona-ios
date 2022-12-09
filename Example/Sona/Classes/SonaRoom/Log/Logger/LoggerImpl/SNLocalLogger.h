//
//  SNLocalLogger.h
//  SonaRoom
//
//  Created by Ju Liaoyuan on 2022/1/19.
//

#import <Foundation/Foundation.h>
#import "SNLoggerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 本地日志，content 只接受 string 类型的 content，其他信息请放在 ext中。
 */
@interface SNLocalLogger : NSObject<SNLoggerProtocol>

@end

NS_ASSUME_NONNULL_END
