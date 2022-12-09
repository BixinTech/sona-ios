//
//  CRMicOperationHandler.m
//  SonaIOSExamples
//
//  Created by Ju Liaoyuan on 2022/11/24.
//

#import "CRMicOperationHandler.h"
#import "CRMessageConstant.h"

#define AVATAR_NAME_PREFIX @"chatroom_img_avatar"

@implementation CRMicOperationHandler


- (BOOL)canHandleMessage:(CRMessageType)type {
    return type == CRMessageTypeMicOperation;
}

- (void)handleMessage:(SNMsgModel *)model {
    NSDictionary *dict = model.data;
    if (dict) {
        NSInteger index = [dict[@"index"] intValue];
        CRSeatView *seat = [self.chatRoom.seatViewContainer viewWithTag:1000+index];
        
        NSInteger opt = [dict[@"operate"] intValue];
        if (opt == 1) {
            CRRoomInfoSeatModel *model = [CRRoomInfoSeatModel new];
            model.uid = dict[@"uid"];
            model.index = index;
            model.avatarName = [NSString stringWithFormat:@"%@_%@", AVATAR_NAME_PREFIX, @(index)];
            [seat bindModel:model];
        } else {
            [seat bindModel:nil];
        }
        if ([dict[@"uid"] isEqualToString:[CRUserCenter defaultCenter].uid] && opt == 1) {
            self.chatRoom.mySeat = seat;
            self.chatRoom.mySeat.showMicBtn = true;
        } else {
            self.chatRoom.mySeat.showMicBtn = false;
            self.chatRoom.mySeat = nil;
        }
    }
}

- (NSString *)makePublicScreenMessage:(SNMsgModel *)model {
    BOOL opt = [model.data[@"operate"] boolValue];
    NSString *uid = model.data[@"uid"];
    NSString *index = [NSString stringWithFormat:@"%@", @([model.data[@"index"] intValue] + 1)];
    return [NSString stringWithFormat:@"用户 %@ %@了 %@ 麦位", uid, opt ? @"上" : @"下", index];
}


@end
