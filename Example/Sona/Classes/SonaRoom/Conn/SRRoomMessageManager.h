//
//  SRRoomMessageManager.h
//  SonaRoom
//
//  Created by Ju Liaoyuan on 2021/1/27.
//

#import <Foundation/Foundation.h>
#import "SRRoomMessageQueueManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface SRRoomMessageManager : NSObject

@property (nonatomic, strong, readonly) SRRoomMessageQueueManager *messageQueue;

@property (nonatomic, assign) NSInteger pollingInterval;

@property (nonatomic, assign) NSInteger messageQueueSize;

- (BOOL)inQueue:(NSString *)messageId;

- (void)startPollingTimer;

- (void)stopPollingTimer;

@end

NS_ASSUME_NONNULL_END
