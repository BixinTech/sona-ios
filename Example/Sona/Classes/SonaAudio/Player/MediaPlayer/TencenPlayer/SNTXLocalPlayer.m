//
//  SNTXLocalPlayer.m
//  SonaAudio
//
//  Created by Ju Liaoyuan on 2022/3/3.
//

#import "SNTXLocalPlayer.h"

@implementation SNTXLocalPlayer

- (NSInteger)playerIdentifier {
    return 4;
}

- (NSString *)genLog:(NSString *)event {
    // 添加前缀
    return [NSString stringWithFormat:@"TX Play Audio %@ (Local)", event];
}

- (BOOL)isPublish {
    return false;
}

- (void)destroy {
    [super destroy];
}

@end
