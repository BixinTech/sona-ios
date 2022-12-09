//
//  SNTXMediaPlayerBase.m
//  SonaAudio
//
//  Created by Ju Liaoyuan on 2022/3/3.
//

#import "SNTXMediaPlayerBase.h"
#import "NSObject+SRUtils.h"
#import "SNSubjectCleaner.h"
#import <TXLiteAVSDK_Professional/TXLiteAVSDK.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "SNMacros.h"
#import "SNLoggerHelper.h"

static NSString * const SNTXMediaPlayerDomain = @"com.sn.mediaplayer.aux";

@interface SNTXMediaPlayerBase ()

@property (nonatomic, strong) TXAudioEffectManager *musicPlayer;

@property (nonatomic, strong) TXAudioMusicParam *musicParams;

@property (nonatomic, strong) RACSubject *eventCallback;

@property (nonatomic, strong) RACSubject *onPlayProgress;

@property (nonatomic, strong) RACSubject *onPlayBegin;

@property (nonatomic, strong) RACSubject *onPlayEnd;

@property (nonatomic, strong) RACSubject *onBufferBegin;

@property (nonatomic, strong) RACSubject *onBufferEnd;

@property (nonatomic, strong) RACSubject *onPlayError;

@property (nonatomic, assign) NSInteger currentVolume;

@property (nonatomic, copy) NSString *currentBgmPath;

@end

@implementation SNTXMediaPlayerBase


- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setPlayerManager:(TXAudioEffectManager *)manager {
    self.musicPlayer = manager;
}

- (void)setup {
    self.currentVolume = 100;
}

- (BOOL)isPublish {
    NSAssert(NO, @"子类重写");
    return false;
}

#pragma mark - Func

- (RACSignal *)playWithPath:(NSString *)path isRepeat:(BOOL)isRepeat {
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        TXAudioMusicParam *params = [TXAudioMusicParam new];
        params.path = path;
        params.ID = (int32_t)[self playerIdentifier];
        params.publish = [self isPublish];
        params.loopCount = isRepeat ? NSIntegerMax : 0;
        
        [self.musicPlayer startPlayMusic:params onStart:^(NSInteger errCode) {
            [self eventLog:[NSString stringWithFormat:@"Start: %@",@(errCode)]];
            if (errCode == 0) {
                self.currentBgmPath = path;
                [self.onPlayBegin sendNext:@1];
                [subscriber sendNext:@1];
            } else {
                self.currentBgmPath = nil;
                NSError *error = [NSError errorWithDomain:SNTXMediaPlayerDomain
                                                     code:errCode
                                                 userInfo:nil];
                [subscriber sendError:error];
                [self.onPlayError sendNext:error];
            }
        } onProgress:^(NSInteger progressMs, NSInteger durationMs) {
            [self.onPlayProgress sendNext:@(progressMs)];
        } onComplete:^(NSInteger errCode) {
            [self eventLog:[NSString stringWithFormat:@"play end: %@",@(errCode)]];
            self.currentBgmPath = nil;
            if (errCode == 0) {
                [self.onPlayEnd sendNext:@1];
            } else {
                [self.onPlayError sendNext:[NSError errorWithDomain:SNTXMediaPlayerDomain
                                                               code:errCode
                                                           userInfo:nil]];
            }
        }];
        return nil;
    }];
}

- (RACSignal *)playVideoWithPath:(NSString *)path isRepeat:(BOOL)isRepeat inView:(UIView *)view {
    return [RACSignal error:[NSError errorWithDomain:SNTXMediaPlayerDomain
                                                code:-1
                                            userInfo:@{NSLocalizedDescriptionKey:@"not support"}]];
}


- (RACSignal *)stop {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        [self eventLog:@"stop"];
        [self.musicPlayer stopPlayMusic:(int32_t)[self playerIdentifier]];
        [subscriber sendNext:@1];
        [subscriber sendCompleted];
        return nil;
    }];
}

- (RACSignal *)pause {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        [self eventLog:@"pause"];
        [self.musicPlayer pausePlayMusic:(int32_t)[self playerIdentifier]];
        [subscriber sendNext:@1];
        [subscriber sendCompleted];
        return nil;
    }];
}

- (RACSignal *)resume {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        [self eventLog:@"resume"];
        [self.musicPlayer resumePlayMusic:(int32_t)[self playerIdentifier]];
        [subscriber sendNext:@1];
        [subscriber sendCompleted];
        return nil;
    }];
}

- (void)setVolume:(NSInteger)volume {
    [self eventLog:[NSString stringWithFormat:@"set volume %@",@(volume)]];
    [self.musicPlayer setMusicPublishVolume:(int32_t)[self playerIdentifier] volume:volume];
    [self.musicPlayer setMusicPlayoutVolume:(int32_t)[self playerIdentifier] volume:volume];
    self.currentVolume = volume;
}

- (NSInteger)volume {
    [self eventLog:[NSString stringWithFormat:@"volume %@",@(self.currentVolume)]];
    return self.currentVolume;
}

- (RACSignal *)duration {
    return [self duration:self.currentBgmPath];
}

- (RACSignal *)duration:(NSString *)path {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSInteger duration = [self.musicPlayer getMusicDurationInMS:path];
        [self eventLog:[NSString stringWithFormat:@"duration %@",@(duration)]];
        [subscriber sendNext:@(duration)];
        [subscriber sendCompleted];
        return nil;
    }];
}

- (RACSignal *)seekTo:(NSInteger)position {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        [self eventLog:[NSString stringWithFormat:@"seek to %@",@(position)]];
        [self.musicPlayer seekMusicToPosInMS:(int32_t)[self playerIdentifier] pts:position];
        [subscriber sendNext:@1];
        [subscriber sendCompleted];
        return nil;
    }];
}

- (NSInteger)getAudioStreamCount {
    return 0;
}


- (NSInteger)playerIdentifier {
    NSAssert(NO, @"子类重写");
    return -1;
}

- (NSString *)genLog:(NSString *)event {
    NSAssert(NO, @"子类实现");
    return @"Abstract";
}

#pragma mark - callback

- (RACSubject *)onPlayProgress {
    if (!_onPlayProgress) {
        _onPlayProgress = [RACSubject new];
    }
    return _onPlayProgress;
}

- (RACSubject *)onPlayBegin {
    if (!_onPlayBegin) {
        _onPlayBegin = [RACSubject subject];
    }
    return _onPlayBegin;
}

- (RACSubject *)onPlayEnd {
    if (!_onPlayEnd) {
        _onPlayEnd = [RACSubject new];
    }
    return _onPlayEnd;
}

- (RACSubject *)onBufferBegin {
    if (!_onBufferBegin) {
        _onBufferBegin = [RACSubject new];
    }
    return _onBufferBegin;
}

- (RACSubject *)onBufferEnd {
    if (!_onBufferEnd) {
        _onBufferEnd = [RACSubject new];
    }
    return _onBufferEnd;
}

- (RACSubject *)onPlayError {
    if (!_onPlayError) {
        _onPlayError = [RACSubject new];
    }
    return _onPlayError;
}

#pragma mark - not support methods

- (void)setView:(UIView *)view {

}

- (BOOL)setAudioStream:(SNPlayerAudioStreamIndex)index {
    return false;
}

- (void)destroy {
    [self.musicPlayer stopPlayMusic:(int32_t)[self playerIdentifier]];
}

#pragma mark - getter

- (RACSubject *)eventCallback {
    if (!_eventCallback) {
        _eventCallback = [RACSubject new];
    }
    return _eventCallback;
}

#pragma mark - convenience

- (void)eventLog:(NSString *)event {
    [self sendLog:[self genLog:event] info:nil];
}

- (void)sendLog:(NSString *)log info:(NSDictionary *)info {
    SN_LOG_LOCAL(@"%@, %@",log, info);
}

@end
