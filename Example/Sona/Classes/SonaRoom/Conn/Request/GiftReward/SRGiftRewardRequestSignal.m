//
//  SRGiftRewardRequestSignal.m
//  SonaRoom
//
//  Created by Insomnia on 2020/4/26.
//

#import "SRGiftRewardRequestSignal.h"
#import "SRRequestClient.h"

@implementation SRGiftRewardRequestSignal
+ (RACSignal *)giftRewardWithArg:(NSDictionary *)arg {
    SRRequest *request = [[SRRequest alloc] initWithMethod:SNRequestMethodPOST];
    request.url = @"/sona/gift/reward";
    request.resClass = [SRGiftRewardResModel class];
    request.arg = arg;
    return [[SRRequestClient shareInstance] signalWithRequest:request];
}
@end
