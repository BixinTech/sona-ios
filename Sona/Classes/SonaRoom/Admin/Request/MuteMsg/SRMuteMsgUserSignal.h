//
//  SRMuteMsgUserSignal.h
//  SonaRoom
//
//  Created by Insomnia on 2020/4/2.
//

#import <Foundation/Foundation.h>

@class RACSignal;

NS_ASSUME_NONNULL_BEGIN

@interface SRMuteMsgUserSignal : NSObject
+ (RACSignal *)muteMsgWithArg:(NSDictionary *)arg;
@end

NS_ASSUME_NONNULL_END
