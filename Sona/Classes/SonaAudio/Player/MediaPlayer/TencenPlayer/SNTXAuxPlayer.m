//
//  SNTXAuxPlayer.m
//  SonaAudio
//
//  Created by Ju Liaoyuan on 2022/3/3.
//

#import "SNTXAuxPlayer.h"

@implementation SNTXAuxPlayer

- (NSInteger)playerIdentifier {
    return 3;
}

- (NSString *)genLog:(NSString *)event {
    // 添加前缀
    return [NSString stringWithFormat:@"TX Play Audio %@ (Aux)", event];
}

- (BOOL)isPublish {
    return true;
}

- (void)destroy {
    [super destroy];
}

@end
