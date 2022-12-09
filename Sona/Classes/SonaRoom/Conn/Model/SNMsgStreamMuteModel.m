//
//  SNMsgMuteModel.m
//  SonaSDK
//
//  Created by Insomnia on 2019/12/17.
//

#import "SNMsgStreamMuteModel.h"
#import "MJExtension.h"


@implementation SNMsgStreamMuteItemModel
@end

@implementation SNMsgStreamMuteModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{
            @"streamList": [SNMsgStreamMuteItemModel class],
            @"accIdList": [SNMsgStreamMuteItemModel class],
    };
}

@end
