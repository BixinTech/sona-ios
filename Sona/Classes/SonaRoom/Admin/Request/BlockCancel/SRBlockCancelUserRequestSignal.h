//
//  SRBlockCancelUserRequestSignal.h
//  SonaRoom
//
//  Created by Insomnia on 2020/3/30.
//

#import <Foundation/Foundation.h>

@class RACSignal;

NS_ASSUME_NONNULL_BEGIN

@interface SRBlockCancelUserRequestSignal : NSObject
+ (RACSignal *)cancelBlockUserWithArg:(NSDictionary *)arg;
@end

NS_ASSUME_NONNULL_END
