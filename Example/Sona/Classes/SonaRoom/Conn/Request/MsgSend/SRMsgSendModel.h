//
//  SRMsgSendModel.h
//  ChatRoom
//
//  Created by Insomnia on 2020/1/16.
//

#import <Foundation/Foundation.h>
#import "SRBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SRMsgFormat) {
    SRMsgFormatTransparent = 100,
    SRMsgFormatText = 101,
    SRMsgFormatImage = 102,
    SRMsgFormatEmoji = 103,
    SRMsgFormatAudio = 104,
    SRMsgFormatVideo = 105,
    SRMsgFormatAck = 106,
};

typedef NS_ENUM(NSUInteger, SRMsgPriority) {
    SRMsgPriorityHigh       = 1,
    SRMsgPriorityMediumHigh = 2,
    SRMsgPriorityMedium     = 3,
    SRMsgPriorityLow        = 4,
};

@interface SRMsgSendModel : SRBaseModel

@property (nonatomic, assign) SRMsgFormat msgFormat;

@property (nonatomic, copy) NSString *messageId;

@property (nonatomic, copy) NSString *msgType;

// json string or binary data
@property (nonatomic, strong) id content;

@property (nonatomic, assign) BOOL needToSave;

/// 默认是 SRMsgPriorityLow
@property (nonatomic, assign) SRMsgPriority priority;

@end

NS_ASSUME_NONNULL_END
