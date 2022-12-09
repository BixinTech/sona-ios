//
//  SRBaseModel.m
//  SonaRoom
//
//  Created by Insomnia on 2019/12/7.
//

#import "SRBaseModel.h"
#import "MJExtension.h"

@implementation SRBaseModel
- (NSString *)description {
    NSString* res = [NSString stringWithFormat:@"/********************Sona Room********************/\n%@", [self mj_JSONString]];
    return res;
}
@end
