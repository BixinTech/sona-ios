//
//  SNAudioMix.m
//  SonaAudio
//
//  Created by Ju Liaoyuan on 2022/1/17.
//

#import "SNAudioMix.h"

@interface SNAudioMix () {
    short *_mixedOutBuf;
}

@property (nonatomic, assign) NSInteger samples;

@end

@implementation SNAudioMix

static inline int16_t fixedValue(short value) {
    if (value > INT16_MAX) {
        value = INT16_MAX;
    }
    if (value < INT16_MIN) {
        value = INT16_MIN;
    }
    return value;
}

- (instancetype)init {
    NSAssert(NO, @"use `- initWithSamples:` instead");
    return [self initWithSamples:0];
}

- (instancetype)initWithSamples:(NSInteger)samples {
    self = [super init];
    if (self) {
        self.samples = samples;
        [self setup];
    }
    return self;
}

- (void)setup {
    self.micVolume = 100;
    self.bgmVolume = 100;
    _mixedOutBuf = new short[_samples];
    memset(_mixedOutBuf, 0, _samples);
}

- (void)dealloc {
    delete [] _mixedOutBuf;
    _mixedOutBuf = nullptr;
}

- (void)processMix:(short *)micBuf bgmBuffer:(short *)bgmBuf mixedOutBuffer:(short **)mixedOutBuf {
    for (int i = 0; i < self.samples; i++) {
        short mic = fixedValue(micBuf ? micBuf[i]*(self.micVolume/100.0) : 0);
        short bgm = fixedValue(bgmBuf ? bgmBuf[i]*(self.bgmVolume/100.0) : 0);
        _mixedOutBuf[i] = fixedValue((mic + bgm));
    }
    if (mixedOutBuf != nullptr) {
        *mixedOutBuf = _mixedOutBuf;
    }
}


@end
