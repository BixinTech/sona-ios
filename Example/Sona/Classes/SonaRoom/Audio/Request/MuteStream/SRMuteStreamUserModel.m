//
//  SRMuteStreamUserModel.m
//  SonaRoom
//
//  Created by Insomnia on 2019/12/21.
//

#import "SRMuteStreamUserModel.h"
#import "MJExtension.h"

@implementation SRMuteStreamUserModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{
            @"targetUids": [NSString class]
    };
}

@end
