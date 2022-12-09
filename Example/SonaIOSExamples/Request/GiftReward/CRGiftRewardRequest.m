//
//  CRGiftRewardRequest.m
//  SonaIOSExamples
//
//  Created by Ju Liaoyuan on 2022/11/14.
//

#import "CRGiftRewardRequest.h"

@implementation CRGiftRewardRequest

+ (RACSignal *)rewardWithRoomId:(NSString *)roomId
                        fromUid:(NSString *)uid
                      targetUid:(NSString *)targetUid
                         giftId:(NSInteger)giftId {
    CRRequest *req = [[CRRequest alloc] initWithMethod:SNRequestMethodPOST];
    req.url = @"/sona/demo/gift/reward";
    req.arg = @{@"giftId":@(giftId),
                @"roomId":roomId ? : @"",
                @"fromUid": uid ? : @"",
                @"toUid": targetUid ? : @""};
    return [[SRRequestClient shareInstance] signalWithRequest:req];
}


@end
