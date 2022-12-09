//
//  CRGiftRewardRequest.h
//  SonaIOSExamples
//
//  Created by Ju Liaoyuan on 2022/11/14.
//

#import "CRRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface CRGiftRewardRequest : CRRequest

+ (RACSignal *)rewardWithRoomId:(NSString *)roomId
                        fromUid:(NSString *)uid
                      targetUid:(NSString *)targetUid
                         giftId:(NSInteger)giftId;

@end

NS_ASSUME_NONNULL_END
