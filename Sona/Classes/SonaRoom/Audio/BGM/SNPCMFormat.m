//
//  SNPCMFormat.m
//  SonaRoom
//
//  Created by Ju Liaoyuan on 2021/12/24.
//

#import "SNPCMFormat.h"

@implementation SNPCMFormat

- (instancetype)initWithSampleRate:(int)sampleRate bitDepth:(int)bitDepth channels:(int)channels {
    self = [super init];
    if (self) {
        _sampleRate = sampleRate;
        _bitDepth = bitDepth;
        _channels = channels;
    }
    return self;
}

@end
