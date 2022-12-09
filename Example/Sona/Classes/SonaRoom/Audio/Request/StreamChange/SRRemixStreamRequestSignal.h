//
//  SRRemixStreamRequestSignal.h
//  SonaRoom
//
//  Created by Ju Liaoyuan on 2021/5/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class RACSignal;

@interface SRRemixStreamRequestSignal : NSObject

+ (RACSignal *)remixStream:(NSString *)roomId;

@end

NS_ASSUME_NONNULL_END
