//
//  SRMuteStreamCancelUserModel.m
//  SonaRoom
//
//  Created by Insomnia on 2019/12/21.
//

#import "SRUnMuteStreamUserModel.h"
#import "MJExtension.h"

@implementation SRUnMuteStreamUserModel
+ (NSDictionary *)mj_objectClassInArray {
    return @{
            @"targetUids": [NSString class]
    };
}
@end
