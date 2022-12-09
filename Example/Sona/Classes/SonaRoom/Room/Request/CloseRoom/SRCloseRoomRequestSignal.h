//
//  SRCloseRoomRequestSignal.h
//  SonaRoom
//
//  Created by Insomnia on 2020/3/10.
//

#import <Foundation/Foundation.h>
#import "SRCloseRoomModel.h"

@class RACSignal;

NS_ASSUME_NONNULL_BEGIN

@interface SRCloseRoomRequestSignal : NSObject
+ (RACSignal *)closeRoomWithModel:(SRCloseRoomModel *)model;

@end

NS_ASSUME_NONNULL_END
