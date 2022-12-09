//
//  SNZGAudioPrepProxy.m
//  SonaAudio
//
//  Created by Ju Liaoyuan on 2021/4/16.
//

#import "SNZGAudioPrepProxy.h"
#import "SNLoggerHelper.h"
#import <ZegoLiveRoom/ZegoLiveRoom.h>
#import <ZegoLiveRoom/ZegoLiveRoomApi-AudioIO.h>
#import "SNThreadSafeArray.h"
#import <thread>

@interface SNZGAudioPrepProxy ()

@property (nonatomic, weak) ZegoLiveRoomApi *api;

@property (atomic, assign) BOOL hasInitConfig;

@end

static SNThreadSafeArray *_processors;
static unsigned char *_outBufPool = nullptr;
static int _outBufPoolSize = 0;
static std::mutex _lock;

@implementation SNZGAudioPrepProxy

- (instancetype)initWithZegoApi:(ZegoLiveRoomApi *)api {
    self = [super init];
    if (self) {
        self.api = api;
        _processors = [SNThreadSafeArray new];
    }
    return self;
}

- (void)initConfig {
    if (self.hasInitConfig) return;
    self.hasInitConfig = true;
    AVE::ExtPrepSet config;
    config.bEncode = false;
    config.nSamples = 441;
    config.nSampleRate = 44100;
    config.nChannel = 2;
    [self.api setAudioPrepCallback:audioPrepCallback config:config];
}

- (void)enableAudioPreprocess:(id<SNAudioPrepProtocol>)processor {
    if (!processor) {
        SN_LOG_LOCAL(@"Sona Logan: enable prep procress fail, processor is nil(ZG)");
        return;
    }
    if ([_processors containsObject:processor]) {
        SN_LOG_LOCAL(@"Sona Logan: procressor has existed(ZG)");
        return;
    }
    if (![processor respondsToSelector:@selector(audioPreprocessWithInFrame:outFrame:length:)]) {
        SN_LOG_LOCAL(@"Sona Logan: enable prep procress fail, please implementation SNAudioPrepProtocol(ZG)");
        return;
    }
    if ([processor respondsToSelector:@selector(audioFrameFormat:sampleRate:presentationTime:)]) {
        [processor audioFrameFormat:2 sampleRate:44100 presentationTime:0.01];
    }
    
    [_processors addObject:processor];
    SN_LOG_LOCAL(@"Sona Logan: enable prep procress: %@(ZG)", processor);
    [self initConfig];
}

- (void)disableAudioPreprocess:(id<SNAudioPrepProtocol>)processor {
    [_processors removeObject:processor];
    SN_LOG_LOCAL(@"Sona Logan: remove processor: %@(ZG)", processor);
}

- (void)closeAudioPreprocess {
    std::lock_guard<std::mutex> lg(_lock);
    self.hasInitConfig = false;
    AVE::ExtPrepSet set;
    [self.api setAudioPrepCallback:nil config:set];
    [_processors removeAllObjects];
    _processors = nil;
    if (_outBufPool != nullptr) {
        free(_outBufPool);
        _outBufPool = nullptr;
    }
}

#pragma mark - audio callback

void audioPrepCallback(const AVE::AudioFrame &inFrame, AVE::AudioFrame &outFrame) {
    std::lock_guard<std::mutex> lg(_lock);
    outFrame.frameType  = inFrame.frameType;
    outFrame.samples    = inFrame.samples;
    outFrame.bytesPerSample = inFrame.bytesPerSample;
    outFrame.channels   = inFrame.channels;
    outFrame.sampleRate = inFrame.sampleRate;
    outFrame.timeStamp  = inFrame.timeStamp;
    outFrame.configLen  = inFrame.configLen;
    outFrame.bufLen     = inFrame.bufLen;
    
    NSUInteger count = _processors.count;
    if (count == 0) {
        memcpy(outFrame.buffer, inFrame.buffer, inFrame.bufLen);
        // 没有 processor，拷贝后直接返回
        return;
    }
    
    if (_outBufPool == nullptr) {
        _outBufPool = (unsigned char *)malloc(inFrame.bufLen);
        _outBufPoolSize = inFrame.bufLen;
    }
    if (_outBufPoolSize < inFrame.bufLen) {
        _outBufPool = (unsigned char *)realloc(_outBufPool, inFrame.bufLen);
        _outBufPoolSize = inFrame.bufLen;
    }
    unsigned char *inBuffer = inFrame.buffer;
    for (int i = 0; i < count; i++) {
        id<SNAudioPrepProtocol> processor = _processors[i];
        if (i != 0) {
            // 非首次，上一次的outBuffer作为本次的
            inBuffer = _outBufPool;
        }
        [processor audioPreprocessWithInFrame:inBuffer outFrame:outFrame.buffer length:inFrame.bufLen];
        if (i != count - 1) {
            // 非最后一个Processor,将上一Processor处理后的outFrame copy 到 pool 里面
            // 目的是为了防止使用 memcpy 出现 memory overlap，导致异常
            memcpy(_outBufPool, outFrame.buffer, inFrame.bufLen);
        }
    }
}

- (void)dealloc {
    SN_LOG_LOCAL(@"Sona Logan: ZGAudioPrepPorxy dealloc");
}


@end
