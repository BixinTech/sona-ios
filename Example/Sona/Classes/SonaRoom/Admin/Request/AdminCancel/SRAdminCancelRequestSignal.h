//
//  SRAdminCancelRequestSignal.h
//  SonaRoom
//
//  Created by Insomnia on 2020/3/30.
//

#import <Foundation/Foundation.h>
#import "SRAdminCancelModel.h"

@class RACSignal;

NS_ASSUME_NONNULL_BEGIN

@interface SRAdminCancelRequestSignal : NSObject
+ (RACSignal *)adminCancelWithArg:(NSDictionary *)arg;
@end

NS_ASSUME_NONNULL_END
