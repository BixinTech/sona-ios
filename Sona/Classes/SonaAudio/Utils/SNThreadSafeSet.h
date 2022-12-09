//
//  SNThreadSafeSet.h
//  SonaAudio
//
//  Created by Ju Liaoyuan on 2022/3/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 A simple implementation of thread safe mutable set.
 
 @discussion referenced source code: YYKit
 
 @warning Fast enumerate(for...in) and enumerator is not thread safe,
 use enumerate using block instead. When enumerate or sort with block/callback,
 do *NOT* send message to the dictionary inside the block/callback.
 */
@interface SNThreadSafeSet : NSMutableSet

@end

NS_ASSUME_NONNULL_END
