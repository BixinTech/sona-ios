//
//  CRMessageHandlerProtocol.h
//  SonaIOSExamples
//
//  Created by Ju Liaoyuan on 2022/11/24.
//

#import <Foundation/Foundation.h>
#import "CRMessageConstant.h"
#import "SNMsgModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CRMessageHandlerProtocol <NSObject>

- (BOOL)canHandleMessage:(CRMessageType)type;

- (void)handleMessage:(SNMsgModel *)model;

@optional
- (NSString *)makePublicScreenMessage:(SNMsgModel *)model;

@end

NS_ASSUME_NONNULL_END
