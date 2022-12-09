//
//  SRRoomMessageQueueManager.h
//  SonaRoom
//
//  Created by Ju Liaoyuan on 2021/1/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SRRoomMessageQueueManager : NSObject

@property (nonatomic, assign) NSInteger capacity;

- (void)enqueue:(NSString *)messageId;

- (NSArray *)allElements;

- (BOOL)contain:(NSString *)messageId;

- (void)removeItemBeforeSentry;

- (void)insertSentry;

@end

NS_ASSUME_NONNULL_END
