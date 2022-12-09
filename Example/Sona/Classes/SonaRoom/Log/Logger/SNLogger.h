//
//  SNLogger.h
//  SonaRoom
//
//  Created by Ju Liaoyuan on 2022/1/19.
//

#import <Foundation/Foundation.h>
#import "SNLoggerConst.h"

@protocol SNLoggerProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface SNLogger : NSObject


+ (instancetype)shared;

// use `+ shared` instead
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 * register logger
 */
- (void)registerLogger:(id<SNLoggerProtocol>)logger forScene:(NSString *)scene;

/**
 * unregister logger
 */
- (void)unregisterLoggerWithScene:(NSString *)scene;

/**
 * log
 */
- (void)logForScene:(NSString *)scene content:(NSString *)content ext:(NSDictionary *)ext;


@end

NS_ASSUME_NONNULL_END
