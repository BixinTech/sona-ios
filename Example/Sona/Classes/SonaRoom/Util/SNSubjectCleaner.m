//
//  SNSubjectCleaner.m
//  SonaRoom
//
//  Created by Ju Liaoyuan on 2021/7/27.
//

#import "SNSubjectCleaner.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "ReactiveCocoa.h"

#define RAC_CLASS_TYPE @"@\"RACSubject\""

@implementation SNSubjectCleaner

+ (void)clear:(NSObject *)target {
    unsigned int count;
    Ivar *ivars = class_copyIvarList([target class], &count);
    for (int i = 0; i < count; i++) {
        Ivar var = ivars[i];
        NSString *classType = [NSString stringWithFormat:@"%s", ivar_getTypeEncoding(var)];
        if (classType && [classType isEqualToString:RAC_CLASS_TYPE]) {
            RACSubject *subject = [target valueForKey:[NSString stringWithFormat:@"%s", ivar_getName(var)]];
            if (subject && [subject isKindOfClass:RACSubject.class]) {
                [subject sendCompleted];
            }
        }
    }
    free(ivars);
}

@end
