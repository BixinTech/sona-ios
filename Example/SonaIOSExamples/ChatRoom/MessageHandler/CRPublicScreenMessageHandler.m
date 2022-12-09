//
//  CRPublicScreenMessageHandler.m
//  SonaIOSExamples
//
//  Created by Ju Liaoyuan on 2022/11/24.
//

#import "CRPublicScreenMessageHandler.h"

@implementation CRPublicScreenMessageHandler


- (BOOL)canHandleMessage:(CRMessageType)type {
    return type == CRMessageTypeRoomMessage;
}

- (void)handleMessage:(SNMsgModel *)model {
    // do nothing
}

- (NSString *)makePublicScreenMessage:(SNMsgModel *)model {
    return [NSString stringWithFormat:@"用户%@: %@", model.data[@"uid"], model.data[@"content"]];
}

@end
