//
//  SRAdminSetSignal.h
//  SonaRoom
//
//  Created by Insomnia on 2020/3/30.
//

#import <Foundation/Foundation.h>
#import "SRAdminSetModel.h"

@class RACSignal;

NS_ASSUME_NONNULL_BEGIN

@interface SRAdminSetRequestSignal : NSObject
+ (RACSignal *)adminSetWithArg:(NSDictionary *)arg;
@end

NS_ASSUME_NONNULL_END
