//
//  SNZGMediaPlayerBase.m
//  SonaAudio
//
//  Created by Ju Liaoyuan on 2021/4/9.
//

#import "SNZGMediaPlayerBase.h"
#import "SNMacros.h"
#import "SNSubjectCleaner.h"
#import "SNLoggerHelper.h"

static NSString * const kSNZGMediaPlayerDomain = @"com.sn.mediaplayer";

typedef NS_ENUM(NSInteger, SNZGCallbackType) {
    SNZGCallbackTypeBGMPlayStart,
    SNZGCallbackTypeBGMStop,
    SNZGCallbackTypeBGMPause,
    SNZGCallbackTypeBGMResume
};

@interface SNZGMediaPlayerBase ()

@property (nonatomic, strong) RACSubject *eventCallback;

@property (nonatomic, strong) RACSubject *onPlayProgress;

@property (nonatomic, strong) RACSubject *onPlayBegin;

@property (nonatomic, strong) RACSubject *onPlayEnd;

@property (nonatomic, strong) RACSubject *onBufferBegin;

@property (nonatomic, strong) RACSubject *onBufferEnd;

@property (nonatomic, strong) RACSubject *onPlayError;

@end

@implementation SNZGMediaPlayerBase

#pragma mark - Func

- (RACSignal *)playWithPath:(NSString *)path isRepeat:(BOOL)isRepeat {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        [self eventLog:[NSString stringWithFormat:@"Will Play Audio:%@",path.description]];
        if ([self isEmptyString:path]) {
            [subscriber sendError:[NSError errorWithDomain:kSNZGMediaPlayerDomain
                                                      code:-1
                                                  userInfo:@{NSLocalizedDescriptionKey:@"url not exist"}]];
            [subscriber sendCompleted];
        } else {
            __block BOOL flag = YES;
            [self.eventCallback subscribeNext:^(RACTuple *tuple) {
                if (flag) {
                    RACTupleUnpack(NSNumber *type, NSNumber * __unused res) = tuple;
                    if ([type integerValue] == SNZGCallbackTypeBGMPlayStart) {
                        [self.onPlayBegin sendNext:@1];
                        flag = NO;
                        [subscriber sendNext:@1];
                        [subscriber sendCompleted];
                    }
                }
            }];
            [self.mediaPlayer stop];
            [self.mediaPlayer start:path repeat:isRepeat];
        }
        return nil;
    }];
}

- (RACSignal *)playVideoWithPath:(NSString *)path isRepeat:(BOOL)isRepeat inView:(UIView *)view {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        [self eventLog:[NSString stringWithFormat:@"Will Play Video:%@",path.description]];
        if ([self isEmptyString:path]) {
            [subscriber sendError:[NSError errorWithDomain:kSNZGMediaPlayerDomain
                                                      code:-1
                                                  userInfo:@{NSLocalizedDescriptionKey:@"url not exist"}]];
            [subscriber sendCompleted];
        } else {
            __block BOOL flag = YES;
            [self.eventCallback subscribeNext:^(RACTuple *tuple) {
                if (flag) {
                    RACTupleUnpack(NSNumber *type, NSNumber * __unused res) = tuple;
                    if ([type integerValue] == SNZGCallbackTypeBGMPlayStart) {
                        flag = NO;
                        [self.onPlayBegin sendNext:@1];
                        [subscriber sendNext:@1];
                        [subscriber sendCompleted];
                    }
                }
            }];
            [self.mediaPlayer stop];
            [self.mediaPlayer setView:view];
            [self.mediaPlayer start:path repeat:isRepeat];
        }
        return nil;
    }];
}

- (RACSignal *)stop {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        [self eventLog:@"Will Stop"];
        __block BOOL flag = YES;
        [self.eventCallback subscribeNext:^(RACTuple *tuple) {
            if (flag) {
                RACTupleUnpack(NSNumber *type, NSNumber * __unused res) = tuple;
                flag = NO;
                if ([type integerValue] == SNZGCallbackTypeBGMStop) {
                    [subscriber sendNext:@1];
                    [subscriber sendCompleted];
                }
            }
        }];
        [self.mediaPlayer stop];
        return nil;
    }];
}

- (RACSignal *)pause {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        [self eventLog:@"Will Pause"];
        __block BOOL flag = YES;
        [self.eventCallback subscribeNext:^(RACTuple *tuple) {
            if (flag) {
                RACTupleUnpack(NSNumber *type, NSNumber * __unused res) = tuple;
                flag = NO;
                if ([type integerValue] == SNZGCallbackTypeBGMPause) {
                    [subscriber sendNext:@1];
                    [subscriber sendCompleted];
                }
            }
        }];
        [self.mediaPlayer pause];
        return nil;
    }];
}

- (RACSignal *)resume {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        [self eventLog:@"Will Resume"];
        __block BOOL flag = YES;
        [self.eventCallback subscribeNext:^(RACTuple *tuple) {
            if (flag) {
                RACTupleUnpack(NSNumber *type, NSNumber * __unused res) = tuple;
                flag = NO;
                if ([type integerValue] == SNZGCallbackTypeBGMResume) {
                    [subscriber sendNext:@1];
                    [subscriber sendCompleted];
                }
            }
        }];
        [self.mediaPlayer resume];
        return nil;
    }];
}

- (void)setVolume:(NSInteger)volume {
    [self eventLog:[NSString stringWithFormat:@"Set Volume:%@",@(volume)]];
    [self.mediaPlayer setVolume:(int)volume];
}

- (NSInteger)volume {
    return (NSInteger)[self.mediaPlayer getPlayVolume];
}

- (RACSignal *)duration {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        NSInteger len = [self.mediaPlayer getDuration];
        [subscriber sendNext:@(len)];
        [subscriber sendCompleted];
        return nil;
    }];
}

- (RACSignal *)duration:(NSString *)path {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@(-1)];
        [subscriber sendCompleted];
        return nil;
    }];
}

- (RACSignal *)seekTo:(NSInteger)position {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        [self eventLog:[NSString stringWithFormat:@"Seek To:%@",@(position)]];
        [self.mediaPlayer seekTo:position];
        [subscriber sendNext:@1];
        [subscriber sendCompleted];
        return nil;
    }];
}

- (void)setView:(UIView *)view {
    [self eventLog:[NSString stringWithFormat:@"Set View:%@",view.description]];
    [self.mediaPlayer setView:view];
}

- (NSInteger)getAudioStreamCount {
    return [self.mediaPlayer getAudioStreamCount];
}

- (BOOL)setAudioStream:(SNPlayerAudioStreamIndex)index {
    long result = [self.mediaPlayer setAudioStream:index];
    [self eventLog:[NSString stringWithFormat:@"Set Audio Stream:%@, Result:%@",@(index), @(result)]];
    if (result == 0) {
        return true;
    } else {
        return false;
    }
}

#pragma mark - callback

- (RACSubject *)onPlayBegin {
    if (!_onPlayBegin) {
        _onPlayBegin = [RACSubject subject];
    }
    return _onPlayBegin;
}

- (RACSubject *)onPlayProgress {
    if (!_onPlayProgress) {
        _onPlayProgress = [RACSubject new];
    }
    return _onPlayProgress;
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

#pragma mark - ZegoMediaPlayerAudioPlayDelegate

- (void)onPlayStart:(ZegoMediaPlayerIndex)index {
    if (![self isMe:index]) {
        return;
    }
    [self eventLog:@"Start"];
    RACTuple *tuple = RACTuplePack(@(SNZGCallbackTypeBGMPlayStart), @(1));
    [self.eventCallback sendNext:tuple];
}

- (void)onPlayEnd:(ZegoMediaPlayerIndex)index {
    if (![self isMe:index]) {
        return;
    }
    [self eventLog:@"End"];
    [self.onPlayEnd sendNext:@(1)];
}

- (void)onPlayStop:(ZegoMediaPlayerIndex)index {
    if (![self isMe:index]) {
        return;
    }
    [self eventLog:@"Stop"];
    RACTuple *tuple = RACTuplePack(@(SNZGCallbackTypeBGMStop), @(1));
    [self.eventCallback sendNext:tuple];
}

- (void)onPlayPause:(ZegoMediaPlayerIndex)index {
    if (![self isMe:index]) {
        return;
    }
    [self eventLog:@"Pause"];
    RACTuple *tuple = RACTuplePack(@(SNZGCallbackTypeBGMPause), @(1));
    [self.eventCallback sendNext:tuple];
}

- (void)onPlayResume:(ZegoMediaPlayerIndex)index {
    if (![self isMe:index]) {
        return;
    }
    [self eventLog:@"Resume"];
    RACTuple *tuple = RACTuplePack(@(SNZGCallbackTypeBGMResume), @(1));
    [self.eventCallback sendNext:tuple];
}

- (void)onProcessInterval:(long)timestamp playerIndex:(ZegoMediaPlayerIndex)index {
    if (![self isMe:index]) {
        return;
    }
    [self.onPlayProgress sendNext:@(timestamp)];
}

- (void)onBufferBegin:(ZegoMediaPlayerIndex)index {
    if (![self isMe:index]) {
        return;
    }
    [self eventLog:@"Buffer Begin"];
    [self.onBufferBegin sendNext:@(1)];
}

- (void)onBufferEnd:(ZegoMediaPlayerIndex)index {
    if (![self isMe:index]) {
        return;
    }
    [self eventLog:@"Buffer End"];
    [self.onBufferEnd sendNext:@(1)];
}

- (void)onPlayError:(int)code playerIndex:(ZegoMediaPlayerIndex)index {
    if (![self isMe:index]) {
        return;
    }
    [self eventLog:[NSString stringWithFormat:@"Error, Code: %@", @(code)]];
    [self.onPlayError sendNext:@(code)];
}

#pragma mark - getter

- (ZegoMediaPlayer *)mediaPlayer {
    NSAssert(NO, @"请实例化子类使用");
    return nil;
}

- (NSInteger)playerIdentifier {
    NSAssert(NO, @"子类重写");
    return -1;
}

- (void)destroy {
    [SNSubjectCleaner clear:self];
}

- (RACSubject *)eventCallback {
    if (!_eventCallback) {
        _eventCallback = [RACSubject new];
    }
    return _eventCallback;
}


#pragma mark - convenience

- (BOOL)isMe:(NSInteger)index {
    return [self playerIdentifier] == index;
}

- (void)eventLog:(NSString *)event {
    [self sendLog:[self genLog:event] info:nil];
}

- (void)sendLog:(NSString *)log info:(NSDictionary *)info {
    SN_LOG_LOCAL(@"%@, %@", log, info);
}

- (NSString *)genLog:(NSString *)event {
    NSAssert(NO, @"子类实现");
    return @"Abstract";
}

- (BOOL)isEmptyString:(NSString *)str {
    return !([str isKindOfClass:[NSString class]] && str.length != 0);
}

@end
