//
//  SNMacros.h
//  SonaSDK
//
//  Created by Insomnia on 2019/12/4.
//

#ifndef SNMacros_h
#define SNMacros_h

#import "ReactiveCocoa.h"
#import "SNCode.h"
#import "NSDictionary+SNProtectedKeyValue.h"

#ifndef SN_LOCK
#define SN_LOCK(lock) dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
#endif

#ifndef SN_UNLOCK
#define SN_UNLOCK(lock) dispatch_semaphore_signal(lock);
#endif


#define NOT_SUPPORT NSAssert(NO, @"not support methods");

#define USE_OTHER(desc) \
    NSString *msg = [NSString stringWithFormat:@"please use %@ instead", desc];        \
    NSAssert(NO, msg);


static inline void sn_dispatch_sync_on_main_thread(void (^block)(void)) {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

#endif /* SNMacros_h */
