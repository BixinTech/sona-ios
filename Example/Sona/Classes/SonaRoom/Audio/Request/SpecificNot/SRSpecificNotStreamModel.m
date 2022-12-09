//
//  SRSpecificNotStreamModel.m
//  SonaRoom
//
//  Created by Insomnia on 2019/12/25.
//

#import "SRSpecificNotStreamModel.h"

@implementation SRSpecificNotStreamModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{
        @"targetUids": [NSString class],
        @"sourceUids": [NSString class]
    };
}

@end
