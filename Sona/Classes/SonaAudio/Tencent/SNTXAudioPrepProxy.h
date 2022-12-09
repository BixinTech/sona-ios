//
//  SNTXAudioPrepProxy.h
//  SonaAudio
//
//  Created by Ju Liaoyuan on 2021/9/22.
//

#import <Foundation/Foundation.h>
#import <TXLiteAVSDK_Professional/TXLiteAVSDK.h>
#import "SNAudioPrepProtocol.h"
#import "SNAudioPreprocessProxy.h"
#import "SNPCMPlayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface SNTXAudioPrepProxy : NSObject<TRTCAudioFrameDelegate, SNAudioPreprocessProxy, SNPCMPlayer>

@end

NS_ASSUME_NONNULL_END
