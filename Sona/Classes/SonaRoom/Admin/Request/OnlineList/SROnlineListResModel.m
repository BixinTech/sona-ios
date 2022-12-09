//
//  SROnlineListResModel.m
//  SonaRoom
//
//  Created by Insomnia on 2019/12/30.
//

#import "SROnlineListResModel.h"
#import "MJExtension.h"

@implementation SROnlineListResItemModel
@end

@implementation SROnlineListResModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{
        @"list": [SROnlineListResItemModel class]
    };
}

@end
