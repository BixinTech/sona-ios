//
//  SRRoomPluginProtocol.h
//  SonaRoom
//
//  Created by Insomnia on 2020/4/3.
//

#import <Foundation/Foundation.h>
#import "SNConfigModel.h"

@class RACTuple, SRRoom;

NS_ASSUME_NONNULL_BEGIN

@protocol SRRoomPluginProtocol <NSObject>

- (void)updateConfigWithModel:(SNConfigModel *)model;

@optional
- (instancetype)initWithTuple:(RACTuple *)tuple;

- (void)registerSuccessWithRoom:(SRRoom *)room;

- (void)didUnregistered;

@end

NS_ASSUME_NONNULL_END
