//
//  SNZGVideoCaptureFactory.m
//  SonaAudio
//
//  Created by Ju Liaoyuan on 2021/4/15.
//

#import "SNZGVideoCaptureFactory.h"
#import <sys/time.h>
#import <memory>
#import <thread>
#import "SNLoggerHelper.h"

@interface SNZGVideoCaptureFactory () <ZegoVideoCaptureDevice> {
    id<ZegoVideoCaptureClientDelegate> _client;
    BOOL _captureStarted;
    std::mutex _captureLock;
    
    CVPixelBufferPoolRef _pool;
    int _videoWidth;
    int _videoHeight;
}


@end

@implementation SNZGVideoCaptureFactory

#pragma mark - ZegoVideoCaptureFactory

- (id<ZegoVideoCaptureDevice>)zego_create:(NSString *)deviceId {
    SN_LOG_LOCAL(@"%s", __func__);
    return self;
}

- (void)zego_destroy:(id<ZegoVideoCaptureDevice>)device {
    SN_LOG_LOCAL(@"%s", __func__);
}

#pragma mark - ZegoVideoCaptureDevice

- (void)zego_allocateAndStart:(id<ZegoVideoCaptureClientDelegate>)client {
    SN_LOG_LOCAL(@"%s", __func__);
    _client = client;
}

- (void)zego_stopAndDeAllocate {
    SN_LOG_LOCAL(@"%s", __func__);
    [_client destroy];
    _client = nil;
}

- (int)zego_startCapture {
    SN_LOG_LOCAL(@"%s", __func__);
    std::lock_guard<std::mutex> lg(_captureLock);
    _captureStarted = YES;
    return 0;
}

- (int)zego_stopCapture {
    SN_LOG_LOCAL(@"%s", __func__);
    std::lock_guard<std::mutex> lg(_captureLock);
    _captureStarted = NO;
    return 0;
}

- (ZegoVideoCaptureDeviceOutputBufferType)zego_supportBufferType {
    return ZegoVideoCaptureDeviceOutputBufferTypeCVPixelBuffer;
}

#pragma mark - ZegoMediaPlayerVideoPlayDelegate

typedef void (*CFTypeDeleter)(CFTypeRef cf);
#define MakeCFTypeHolder(ptr) std::unique_ptr<void, CFTypeDeleter>(ptr, CFRelease)

- (void)onPlayVideoData:(const char *)data size:(int)size format:(ZegoMediaPlayerVideoDataFormat)format playerIndex:(ZegoMediaPlayerIndex)index {
    struct timeval tv_now;
    gettimeofday(&tv_now, NULL);
    unsigned long long timeMS = (unsigned long long)(tv_now.tv_sec) * 1000 + tv_now.tv_usec / 1000;
    
    CVPixelBufferRef pixelBuffer = [self createInputBufferWithWidth:format.width height:format.height stride:format.strides[0]];
    
    if (pixelBuffer == NULL) return;
    
    auto holder = MakeCFTypeHolder(pixelBuffer);
    
    CVReturn cvRet = CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    if (cvRet != kCVReturnSuccess) return;
    
    size_t destStride = CVPixelBufferGetBytesPerRow(pixelBuffer);
    unsigned char *dest = (unsigned char *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    unsigned char *src = (unsigned char *)data;
    for (int i = 0; i < format.height; i++) {
        memcpy(dest, src, format.strides[0]);
        src += format.strides[0];
        dest += destStride;
    }
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    [self handleFrame:pixelBuffer time:timeMS];
}

#pragma mark - Private

- (void)createPixelBufferPool {
    NSDictionary *pixelBufferAttributes = @{
                                            (id)kCVPixelBufferOpenGLCompatibilityKey: @(YES),
                                            (id)kCVPixelBufferWidthKey: @(_videoWidth),
                                            (id)kCVPixelBufferHeightKey: @(_videoHeight),
                                            (id)kCVPixelBufferIOSurfacePropertiesKey: [NSDictionary dictionary],
                                            (id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)
                                            };
    
    CFDictionaryRef ref = (__bridge CFDictionaryRef)pixelBufferAttributes;
    CVReturn ret = CVPixelBufferPoolCreate(nil, nil, ref, &_pool);
    if (ret != kCVReturnSuccess) {
        return ;
    }
}

- (CVPixelBufferRef)createInputBufferWithWidth:(int)width height:(int)height stride:(int)stride {
    if (_videoWidth != width || _videoHeight != height) {
        if (_videoHeight && _videoWidth) {
            CVPixelBufferPoolFlushFlags flag = 0;
            CVPixelBufferPoolFlush(_pool, flag);
            CFRelease(_pool);
            _pool = nil;
        }
        
        _videoWidth = width;
        _videoHeight = height;
        [self createPixelBufferPool];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(onVideoSizeChanged:)]) {
            [self.delegate onVideoSizeChanged:CGSizeMake(width, height)];
        }
    }
    
    CVPixelBufferRef pixelBuffer;
    CVReturn ret = CVPixelBufferPoolCreatePixelBuffer(nil, _pool, &pixelBuffer);
    if (ret != kCVReturnSuccess)
        return nil;
    
    return pixelBuffer;
}

- (void)handleFrame:(CVPixelBufferRef)frame time:(unsigned long long)timeMS {
    CMTime pts = CMTimeMake(timeMS, 1000);
    std::lock_guard<std::mutex> lg(_captureLock);
    if (_captureStarted) {
        [_client onIncomingCapturedData:frame withPresentationTimeStamp:pts];
    }
}

@end
