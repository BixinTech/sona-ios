//
//  SNMsgModel.h
//  SonaSDK
//
//  Created by Insomnia on 2019/12/4.
//

#import <Foundation/Foundation.h>
#import "SNModel.h"
#import "SNMsgTypeDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface SNMsgModel : SNModel

@property (nonatomic, copy) NSString *msgType;

@property (nonatomic, copy) NSString *roomId;

@property (nonatomic, copy) NSString *messageId;

@property (nonatomic, copy) NSDictionary *data;

@property (nonatomic, assign) BOOL isAckMsg;

@end

NS_ASSUME_NONNULL_END
