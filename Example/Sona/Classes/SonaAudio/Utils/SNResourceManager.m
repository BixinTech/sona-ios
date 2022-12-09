//
//  SNResourceManager.m
//  SonaAudio
//
//  Created by Ju Liaoyuan on 2022/1/13.
//

#import "SNResourceManager.h"

@implementation SNResourceManager

+ (NSString *)pathForResource:(NSString *)name type:(NSString *)type {
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"SonaAudioRes" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    return [bundle pathForResource:name ofType:type];
}

@end
