//
//  SRGiftRewardModel.h
//  SonaRoom
//
//  Created by Insomnia on 2020/4/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SRGiftRewardModel : NSObject
@property (nonatomic, copy) NSArray <NSString *> *toUids;
@property (nonatomic, copy) NSString *giftId;
@property (nonatomic, assign) NSInteger amount;
@property (nonatomic, assign) NSInteger giftType;
@property (nonatomic, copy) NSString *doubleHitBehaviorKey;
@property (nonatomic, assign) BOOL rewardAll;
@end

NS_ASSUME_NONNULL_END
