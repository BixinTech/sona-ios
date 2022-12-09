//
//  SRGiftRewardRequestSignal.h
//  SonaRoom
//
//  Created by Insomnia on 2020/4/26.
//

#import <Foundation/Foundation.h>
#import "SRGiftRewardModel.h"
#import "SRGiftRewardResModel.h"

@class RACSignal;

NS_ASSUME_NONNULL_BEGIN

@interface SRGiftRewardRequestSignal : NSObject
+ (RACSignal *)giftRewardWithArg:(NSDictionary *)arg;
@end

NS_ASSUME_NONNULL_END
