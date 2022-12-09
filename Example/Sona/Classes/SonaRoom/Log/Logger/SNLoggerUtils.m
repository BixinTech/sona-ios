//
//  SNLoggerUtils.m
//  SonaRoom
//
//  Created by Ju Liaoyuan on 2022/1/19.
//

#import "SNLoggerUtils.h"
#import "SNLoggerConst.h"

@implementation SNLoggerUtils

+ (NSDictionary *)removePrivateKey:(NSDictionary *)origin {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:origin];
    NSMutableArray *needRemoveKeys = @[].mutableCopy;
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString *key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([key hasPrefix:SNLoggerPrivateContentPrefixKey]) {
            [needRemoveKeys addObject:key];
        }
    }];
    [dict removeObjectsForKeys:needRemoveKeys];
    return dict;
}

@end
