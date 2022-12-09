//
//  SNLoggerUtils.h
//  SonaRoom
//
//  Created by Ju Liaoyuan on 2022/1/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SNLoggerUtils : NSObject

/**
 * It will return a new dictionary,  and *not* modify origin dictionary.
 */
+ (NSDictionary *)removePrivateKey:(NSDictionary *)origin;

@end

NS_ASSUME_NONNULL_END
