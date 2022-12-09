//
//  SNMsgGiftRewardModel.m
//  SonaRoom
//
//  Created by Insomnia on 2020/5/7.
//

#import "SNMsgGiftRewardModel.h"
#import "MJExtension.h"

@implementation SNMsgGiftRewardGiftModel
@end

@implementation SNMsgGiftRewardUserModel
@end

@implementation SNMsgGiftRewardModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{
        @"fromUser" : [SNMsgGiftRewardUserModel class],
        @"gift" : [SNMsgGiftRewardGiftModel class],
        @"toUserList" : [SNMsgGiftRewardUserModel class]
    };
}

@end
