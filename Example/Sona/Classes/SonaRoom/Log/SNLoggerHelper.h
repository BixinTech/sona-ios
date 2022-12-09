//
//  SNLoggerHelper.h
//  SonaRoom
//
//  Created by Ju Liaoyuan on 2022/1/21.
//

#import <Foundation/Foundation.h>
#import "SNLogger.h"
#import "NSString+LogPrefix.h"

static NSString * const SNLoggerDefaultPrefix = @"Sona Log";

#define SN_LOG_H [SNLoggerHelper shared]

/// With default prefix(Sona Log)
#define SN_LOG_LOCAL(format, ...) \
[SN_LOG_H localLog:[NSString stringWithFormat:format, ## __VA_ARGS__] prefix:nil ext:nil]

@interface SNLoggerHelper : NSObject

@property (nonatomic, copy) NSString *roomId;

+ (instancetype)shared;

- (void)clearData;

/// ---------------------------------
/// 尽量避免直接使用以下方法，而使用宏代替
/// ---------------------------------

/** 本地日志
 *  @param content 描述
 *  @param prefix 日志前缀，为空时，默认为 "[Sona Log]"
 *  @param ext 扩展字段
 */
- (void)localLog:(NSString *)content prefix:(NSString *)prefix ext:(NSDictionary *)ext;

@end
