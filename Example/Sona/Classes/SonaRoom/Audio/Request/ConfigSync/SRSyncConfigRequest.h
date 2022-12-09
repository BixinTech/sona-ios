//
//  SRSyncConfigRequest.h
//  SonaRoom
//
//  Created by Ju Liaoyuan on 2021/8/18.
//

#import <Foundation/Foundation.h>

@class RACSignal;

NS_ASSUME_NONNULL_BEGIN

@interface SRSyncConfigRequest : NSObject

+ (RACSignal *)syncConfigWithRoomId:(NSString *)roomId;

@end

NS_ASSUME_NONNULL_END
