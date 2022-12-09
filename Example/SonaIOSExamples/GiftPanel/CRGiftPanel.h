//
//  CRGiftPanel.h
//  SonaIOSExamples
//
//  Created by Ju Liaoyuan on 2022/11/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CRGiftModel, CRRoomInfoSeatModel, CRGiftRewardTarget;

@interface CRGiftPanel : UIView

@property (nonatomic, copy) void(^onReward)(CRGiftRewardTarget *target);


- (void)reset;

- (void)updateUserList:(NSArray <CRRoomInfoSeatModel *> *)seatList;

- (void)updateGiftList:(NSArray <CRGiftModel *> *)giftList;

@end

NS_ASSUME_NONNULL_END
