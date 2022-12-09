//
//  CRMessageHandlerBase.m
//  SonaIOSExamples
//
//  Created by Ju Liaoyuan on 2022/11/24.
//

#import "CRMessageHandlerBase.h"

#define NEVER_CALL_ME NSAssert(NO, @"Subclass should override this method");

@implementation CRMessageHandlerBase

- (instancetype)initWithChatRoomVC:(ChatRoomViewController *)vc {
    self = [super init];
    if (self) {
        self.chatRoom = vc;
    }
    return self;
}

#pragma mark - Message Handler Protocol

- (BOOL)canHandleMessage:(CRMessageType)type {
    NEVER_CALL_ME
    return false;
}

- (void)handleMessage:(SNMsgModel *)model {
    NEVER_CALL_ME
}

- (NSString *)makePublicScreenMessage:(SNMsgModel *)model {
    NEVER_CALL_ME
    return nil;
}

@end
