//
//  SRSpecificStreamModel.m
//  SonaRoom
//
//  Created by Insomnia on 2019/12/24.
//

#import "SRSpecificStreamModel.h"
#import "MJExtension.h"

@implementation SRSpecificStreamModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{
        @"targetUids": [NSString class],
        @"sourceUids": [NSString class]
    };
}

@end
