//
//  SRMsgSendModel.m
//  ChatRoom
//
//  Created by Insomnia on 2020/1/16.
//

#import "SRMsgSendModel.h"

@implementation SRMsgSendModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.priority = SRMsgPriorityLow;
    }
    return self;
}


@end
