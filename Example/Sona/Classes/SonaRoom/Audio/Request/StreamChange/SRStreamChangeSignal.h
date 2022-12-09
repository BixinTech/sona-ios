//
//  SRStreamChangeSignal.h
//  SonaRoom
//
//  Created by Insomnia on 2020/7/25.
//

#import <Foundation/Foundation.h>

@class RACSignal;

NS_ASSUME_NONNULL_BEGIN

@interface SRStreamChangeSignal : NSObject
+ (RACSignal *)streamChangeWith:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
