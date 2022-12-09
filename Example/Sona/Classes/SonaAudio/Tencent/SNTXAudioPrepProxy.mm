//
//  SNTXAudioPrepProxy.m
//  SonaAudio
//
//  Created by Ju Liaoyuan on 2021/9/22.
//

#import "SNTXAudioPrepProxy.h"
#import "SNLoggerHelper.h"
#import "SNThreadSafeArray.h"
#import "SNAudioMix.h"
#import <thread>


#define PCM_MIXED_OUTPUT_SAMPLE_RATE 44100
#define PCM_SAMPLE_RATE 48000
#define PCM_CHANNELS 2
#define PCM_BIT_DEPTH 16
#define PCM_DURATION 0.02

static unsigned char *_outerBuf = nullptr;
static unsigned char *_originBuf = nullptr;

@interface SNTXAudioPrepProxy () {
    std::mutex _captureLock;
}

@property (nonatomic, strong) SNAudioMix *mixer;

@property (nonatomic, strong) SNThreadSafeArray *processors;

@property (nonatomic, strong) SNPCMFormat *pcmFormat;

@property (atomic, assign) bool shouldMix;

@property (nonatomic, assign) NSInteger currentVolume;

@end

@implementation SNTXAudioPrepProxy

@synthesize provider = _provider;

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)dealloc {
    SN_LOG_LOCAL(@"Sona Logan: SNTXAudioPrepProxy dealloc");
}

- (void)setup {
    
    self.processors = [SNThreadSafeArray new];
    
    _currentVolume = 30;
    
    _pcmFormat = [[SNPCMFormat alloc] initWithSampleRate:PCM_MIXED_OUTPUT_SAMPLE_RATE
                                                bitDepth:PCM_BIT_DEPTH
                                                channels:PCM_CHANNELS];
    
    self.mixer = [[SNAudioMix alloc] initWithSamples:PCM_DURATION*PCM_SAMPLE_RATE];
    self.mixer.bgmVolume = _currentVolume;
}

- (void)enableAudioPreprocess:(id<SNAudioPrepProtocol>)processor {
    if (!processor) {
        SN_LOG_LOCAL(@"Sona Logan: enable prep procress fail, processor is nil(TX)");
        return;
    }
    if ([_processors containsObject:processor]) {
        SN_LOG_LOCAL(@"Sona Logan: procressor has existed(TX)");
        return;
    }
    if (![processor respondsToSelector:@selector(audioPreprocessWithInFrame:outFrame:length:)]) {
        SN_LOG_LOCAL(@"Sona Logan: enable prep procress fail, please implementation SNAudioPrepProtocol(TX)");
        return;
    }
    if ([processor respondsToSelector:@selector(audioFrameFormat:sampleRate:presentationTime:)]) {
        [processor audioFrameFormat:PCM_CHANNELS sampleRate:PCM_SAMPLE_RATE presentationTime:PCM_DURATION];
    }
    [self.processors addObject:processor];
    SN_LOG_LOCAL(@"Sona Logan: enable prep procress: %@(TX)", processor);
}

- (void)disableAudioPreprocess:(id<SNAudioPrepProtocol>)processor {
    [self.processors removeObject:processor];
    SN_LOG_LOCAL(@"Sona Logan: remove processor: %@(TX)", processor);
}

- (void)closeAudioPreprocess {
    [self.processors removeAllObjects];
}

- (void)onLocalProcessedAudioFrame:(TRTCAudioFrame *)frame {
    if (self.processors.count == 0) return;
    
    unsigned char *inFrame = (unsigned char *)[frame.data bytes];
    unsigned long length = frame.data.length;
    NSUInteger count = self.processors.count;
    for (int i = 0; i < count; i++) {
        id<SNAudioPrepProtocol> processor = self.processors[i];
        unsigned char *outFrame = (unsigned char *)malloc(length);
        [processor audioPreprocessWithInFrame:inFrame outFrame:outFrame length:(int)length];
        NSData *result = [NSData dataWithBytes:outFrame length:length];
        if (result) {
            memcpy((char *)frame.data.bytes, result.bytes, frame.data.length);
        }
        free(outFrame);
    }
}
    
- (void)onMixedPlayAudioFrame:(TRTCAudioFrame *)frame {
    std::lock_guard<std::mutex> lg(_captureLock);
    if (!self.shouldMix) {
        return;
    }
    if (!self.mixer || !_provider) {
        return;
    }

    int length = (int)frame.data.length;
    
    size_t space_size = sizeof(unsigned char) * length;
    // 初始化并重置复用池
    if (_outerBuf == nullptr) {
        _outerBuf = (unsigned char *)malloc(space_size);
        memset(_outerBuf, 0, space_size);
    }
    if (_originBuf == nullptr) {
        _originBuf = (unsigned char *)malloc(space_size);
        memset(_originBuf, 0, space_size);
    }
    
    // 获取需要混音的 PCM 数据
    int expectLength = length;
    [_provider onPlayPCMData:_outerBuf length:&expectLength];

    int16_t *mixedBuf = nullptr;
    if (expectLength != 0 && _outerBuf != nullptr) {
        memcpy(_originBuf, (unsigned char *)frame.data.bytes, length);
        [self.mixer processMix:(int16_t *)_originBuf bgmBuffer:(int16_t *)_outerBuf mixedOutBuffer:&mixedBuf];
    }
    
    // 把混好的数据，再回传给 TRTC
    if (mixedBuf != nullptr) {
        memcpy((unsigned char *)frame.data.bytes, mixedBuf, space_size);
    }
    
    // 清空复用池
    memset(_outerBuf, 0, space_size);
    memset(_originBuf, 0, space_size);
}

#pragma mark - PCM Player

- (void)startPlay {
    if (!_provider || ![_provider respondsToSelector:@selector(onPlayPCMData:length:)]) {
        NSAssert(NO, @"pcm provider is invalid");
        return;
    }
    self.shouldMix = true;
}

- (void)stopPlay {
    self.shouldMix = false;
}

- (SNPCMFormat *)getPCMFormat {
    return _pcmFormat;
}

- (void)setProvider:(id<SNPCMPlayerProvider>)provider {
    _provider = provider;
    SN_LOG_LOCAL(@"Sona Logan: pcm provider:%@", provider);
}

- (void)destroy {
    std::lock_guard<std::mutex> lg(_captureLock);
    [self stopPlay];
    if (_outerBuf) {
        free(_outerBuf);
        _outerBuf = nullptr;
    }
    
    if (_originBuf) {
        free(_originBuf);
        _originBuf = nullptr;
    }
}

- (void)setVolume:(int)volume {
    self.mixer.bgmVolume = volume;
    self.currentVolume = volume;
}


- (int)volume {
    return (int)self.currentVolume;
}


@end
