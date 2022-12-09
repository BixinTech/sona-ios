//
//  SRBlockUserRequestSignal.h
//  SonaRoom
//
//  Created by Insomnia on 2020/3/30.
//

#import <Foundation/Foundation.h>


@class RACSignal;
NS_ASSUME_NONNULL_BEGIN

@interface SRBlockUserRequestSignal : NSObject
+ (RACSignal *)blockUserWithArg:(NSDictionary *)arg;
@end

NS_ASSUME_NONNULL_END
