//
//  SRStreamMixVideoRequestSignal.h
//  SonaAudio
//
//  Created by Ju Liaoyuan on 2021/4/16.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

@class RACSignal;

@interface SRStreamMixVideoRequestSignal : NSObject

+ (RACSignal *)mixedVideo:(BOOL)enabled roomId:(NSString *)roomId size:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
