//
//  SNLocalLogger.m
//  SonaRoom
//
//  Created by Ju Liaoyuan on 2022/1/19.
//

#import "SNLocalLogger.h"

#import "SNLoggerConst.h"

@implementation SNLocalLogger

- (void)logWithContent:(NSString *)content ext:(NSDictionary *)ext {
    if (![content isKindOfClass:NSString.class]) {
        return;
    }
    NSLog(@"%@, Ext: %@", content, ext.description);
}

+ (NSString *)sceneKey {
    return @"local";
}

@end
