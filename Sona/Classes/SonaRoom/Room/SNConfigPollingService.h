//
//  SNConfigPollingService.h
//  SonaRoom
//
//  Created by Ju Liaoyuan on 2021/8/18.
//

#import <Foundation/Foundation.h>

@class SRSyncConfigModel;

NS_ASSUME_NONNULL_BEGIN

@interface SNConfigPollingService : NSObject

@property (nonatomic, copy) NSString *targetRoomId;

@property (nonatomic, copy) void(^onGetConfig)(SRSyncConfigModel *__nullable newValue, NSError * __nullable error);

- (void)startPolling:(BOOL)infinite;

- (void)stopPolling;

@end

NS_ASSUME_NONNULL_END
