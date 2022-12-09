//
//  SNMsgTypeStreamStopPublishModel.h
//  ChatRoom
//
//  Created by Insomnia on 2020/2/13.
//

#import <Foundation/Foundation.h>
#import "SNMsgModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SNMsgStreamStopPublishModel : SNMsgModel
@property(nonatomic, copy) NSString *streamId;
@property(nonatomic, copy) NSString *accId;
@end

NS_ASSUME_NONNULL_END
