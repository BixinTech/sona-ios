//
//  SNZGSeiService.h
//  SonaAudio
//
//  Created by Ju Liaoyuan on 2021/4/25.
//

#import <Foundation/Foundation.h>

@class ZegoLiveRoomApi;

@protocol SNZGSeiServiceDelegate <NSObject>

@optional
- (void)onReceiveSeiMessage:(NSDictionary *)message streamId:(NSString *)streamId;

@end

NS_ASSUME_NONNULL_BEGIN

@interface SNZGSeiService : NSObject

@property (nonatomic, weak) id<SNZGSeiServiceDelegate> delegate;

- (instancetype)initWithZegoApi:(ZegoLiveRoomApi *)api;

- (void)sendMessage:(NSDictionary *)message;

@end

NS_ASSUME_NONNULL_END
