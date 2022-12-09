//
//  SNPCMFormat.h
//  SonaRoom
//
//  Created by Ju Liaoyuan on 2021/12/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SNPCMFormat : NSObject

@property (nonatomic, assign) int sampleRate;

@property (nonatomic, assign) int bitDepth;

@property (nonatomic, assign) int channels;

- (instancetype)initWithSampleRate:(int)sampleRate
                          bitDepth:(int)bitDepth
                          channels:(int)channels;

@end

NS_ASSUME_NONNULL_END
