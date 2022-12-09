//
//  SROnlineNumSignal.h
//  SonaRoom
//
//  Created by Insomnia on 2020/4/2.
//

#import <Foundation/Foundation.h>

@class RACSignal;

NS_ASSUME_NONNULL_BEGIN

@interface SROnlineNumSignal : NSObject
+ (RACSignal *)onlineNumWithRoomId:(NSString *)roomId;
@end

NS_ASSUME_NONNULL_END
