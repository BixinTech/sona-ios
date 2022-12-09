//
//  CRRewardMessageHandler.m
//  SonaIOSExamples
//
//  Created by Ju Liaoyuan on 2022/11/24.
//

#import "CRRewardMessageHandler.h"

@implementation CRRewardMessageHandler

- (BOOL)canHandleMessage:(CRMessageType)type {
    return type == CRMessageTypeReward;
}

- (void)handleMessage:(SNMsgModel *)model {
    [self.chatRoom.fullScreenAnimation startAnimation];
}

- (NSString *)makePublicScreenMessage:(SNMsgModel *)model {
    return nil;
}

@end
