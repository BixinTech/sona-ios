//
//  SRCreateRoomRequestSignal.h
//  SonaRoom
//
//  Created by Insomnia on 2020/3/10.
//

#import <Foundation/Foundation.h>
#import "SRCreateRoomModel.h"

@class RACSignal;
NS_ASSUME_NONNULL_BEGIN

@interface SRCreateRoomRequestSignal : NSObject
+ (RACSignal *)createRoomWithModel:(SRCreateRoomModel *)model;
@end

NS_ASSUME_NONNULL_END
