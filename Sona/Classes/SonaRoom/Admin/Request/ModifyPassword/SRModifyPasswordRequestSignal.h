//
//  SRModifyPasswordRequestSignal.h
//  Sona
//
//  Created by Ju Liaoyuan on 2022/10/19.
//

#import <Foundation/Foundation.h>

@class RACSignal;

NS_ASSUME_NONNULL_BEGIN

@interface SRModifyPasswordRequestSignal : NSObject

+ (RACSignal *)modifyPassword:(NSDictionary *)arg;

@end

NS_ASSUME_NONNULL_END
