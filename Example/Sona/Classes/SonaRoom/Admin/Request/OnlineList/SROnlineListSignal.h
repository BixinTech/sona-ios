//
//  SROnlineListSignal.h
//  SonaRoom
//
//  Created by Insomnia on 2020/4/2.
//

#import <Foundation/Foundation.h>

@class RACSignal;

NS_ASSUME_NONNULL_BEGIN

@interface SROnlineListSignal : NSObject
+ (RACSignal *)onlineListWithArg:(NSDictionary *)arg;
@end

NS_ASSUME_NONNULL_END
