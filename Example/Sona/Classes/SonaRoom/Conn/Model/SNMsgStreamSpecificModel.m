//
//  SNMsgTypeStreamSpecificModel.m
//  SonaSDK
//
//  Created by Insomnia on 2019/12/25.
//

#import "SNMsgStreamSpecificModel.h"

@implementation SNMsgStreamSpecificModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{
            @"streamList": [NSString class],
            @"accIdList": [NSString class],
            @"receive": [NSString class],
            @"abort": [NSString class]
    };
}
@end
