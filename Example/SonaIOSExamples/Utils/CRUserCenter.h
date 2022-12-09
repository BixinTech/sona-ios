//
//  CRUserCenter.h
//  SonaIOSExamples
//
//  Created by Ju Liaoyuan on 2022/11/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CRUserCenter : NSObject

@property (nonatomic, copy, readonly) NSString *uid;

+ (instancetype)defaultCenter;

@end

NS_ASSUME_NONNULL_END
