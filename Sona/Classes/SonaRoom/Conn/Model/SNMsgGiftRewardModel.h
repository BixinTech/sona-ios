//
//  SNMsgGiftRewardModel.h
//  SonaRoom
//
//  Created by Insomnia on 2020/5/7.
//

#import <Foundation/Foundation.h>
#import "SNMsgModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SNMsgGiftRewardGiftModel : NSObject
@property(nonatomic, assign) NSInteger giftDuration;
@property(nonatomic, copy) NSString *giftId;
@property(nonatomic, copy) NSString *giftImg;
@property(nonatomic, copy) NSString *giftName;
@property(nonatomic, assign) double giftPrice;
@property(nonatomic, copy) NSString *giftAnimation;
@end

@interface SNMsgGiftRewardUserModel : NSObject
@property(nonatomic, assign) NSInteger age;
@property(nonatomic, copy) NSString *avatar;
@property(nonatomic, assign) NSInteger birthday;
@property(nonatomic, assign) NSInteger gender;
@property(nonatomic, assign) NSInteger isFreeze;
@property(nonatomic, copy) NSString *nickname;
@property(nonatomic, assign) NSInteger showNo;
@property(nonatomic, copy) NSString *uid;
@property(nonatomic, copy) NSString *userId;
@end

@interface SNMsgGiftRewardModel : SNMsgModel
@property(nonatomic, assign) NSInteger amount;
@property(nonatomic, copy) NSDictionary *ext;
@property(nonatomic, strong) SNMsgGiftRewardUserModel *fromUser;
@property(nonatomic, strong) SNMsgGiftRewardGiftModel *gift;
@property(nonatomic, copy) NSArray<SNMsgGiftRewardUserModel *> *toUserList;
@end

NS_ASSUME_NONNULL_END
