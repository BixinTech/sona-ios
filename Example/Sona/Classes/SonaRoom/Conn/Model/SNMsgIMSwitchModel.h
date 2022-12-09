//
//  SNMsgIMSwitchModel.h
//  ChatRoom
//
//  Created by Insomnia on 2020/8/13.
//

#import <Foundation/Foundation.h>
#import "SNMsgModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SNMsgIMSwitchModel : SNMsgModel
@property(nonatomic, copy) NSString *imType;
@property (nonatomic, assign) NSInteger imSendType;
@end

NS_ASSUME_NONNULL_END
