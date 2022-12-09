//
//  SNZGVideoCaptureFactory.h
//  SonaAudio
//
//  Created by Ju Liaoyuan on 2021/4/15.
//

#import <Foundation/Foundation.h>
#import <ZegoLiveRoom/ZegoLiveRoom.h>
#import <ZegoLiveRoom/zego-api-mediaplayer-oc.h>
#import <ZegoLiveRoom/zego-api-external-video-capture-oc.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SNZGVideoCaptureFactoryDelegate <NSObject>

@optional
- (void)onVideoSizeChanged:(CGSize)size;

@end

@interface SNZGVideoCaptureFactory : NSObject <ZegoVideoCaptureFactory, ZegoMediaPlayerVideoPlayWithIndexDelegate>

@property (nonatomic, weak) id<SNZGVideoCaptureFactoryDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
