//
//  SNThreadSafeSet.h
//  SonaAudio
//
//  Created by Ju Liaoyuan on 2022/3/8.
//


#import <Foundation/Foundation.h>

/**
 A simple implementation of thread safe mutable dictionary.
 
 @discussion Generally, access performance is lower than NSMutableDictionary,
 but higher than using @synchronized, NSLock, or pthread_mutex_t.
 
 @discussion It's also compatible with the custom methods in `NSDictionary(YYAdd)`
 and `NSMutableDictionary(YYAdd)`
 
 @discussion source code from YYKit
 
 @warning Fast enumerate(for...in) and enumerator is not thread safe,
 use enumerate using block instead. When enumerate or sort with block/callback,
 do *NOT* send message to the dictionary inside the block/callback.
 */
@interface SNThreadSafeDictionary : NSMutableDictionary

@end
