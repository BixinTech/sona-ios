//
//  SRRoomAdmin.m
//  SonaRoom
//
//  Created by Insomnia on 2019/12/9.
//

#import "SRRoomAdmin.h"
#import "SRCreateRoomRequestSignal.h"
#import "SRCloseRoomRequestSignal.h"
#import "SRMuteMsgUserSignal.h"
#import "SRMuteMsgCancelSignal.h"
#import "SRKickUserRequestSignal.h"
#import "SRBlockCancelUserRequestSignal.h"
#import "SRBlockUserRequestSignal.h"
#import "SRAdminSetRequestSignal.h"
#import "SRAdminCancelRequestSignal.h"
#import "SROnlineNumSignal.h"
#import "SROnlineListSignal.h"
#import "SRModifyPasswordRequestSignal.h"

#import "SNSDK.h"

@interface SRRoomAdmin ()
@property(nonatomic, strong) SNSDK *sdk;
@property(nonatomic, strong) SNConfigModel *configModel;
@end

@implementation SRRoomAdmin
- (instancetype)initWithTuple:(RACTuple *)tuple {
    self = [SRRoomAdmin new];
    if (self) {
        RACTupleUnpack(SNSDK *sdk, SNConfigModel *configModel) = tuple;
        self.sdk = sdk;
        self.configModel = configModel;
    }
    return self;
}
- (RACSignal *)muteMsgUserWithModel:(SRMuteMsgUserModel *)model {
    return [SRMuteMsgUserSignal muteMsgWithArg:[model mj_keyValues]];
}

- (RACSignal *)muteMsgCancelUserWithModel:(SRMuteMsgCancelUserModel *)model {
    return [SRMuteMsgCancelSignal cancelMuteMsgWithArg:[model mj_keyValues]];
}

- (RACSignal *)blockUserWithModel:(SRBlockUserModel *)model {
    return [SRBlockUserRequestSignal blockUserWithArg:[model mj_keyValues]];
}

- (RACSignal *)blockCancelUserWithModel:(SRBlockCancelUserModel *)model {
    return [SRBlockCancelUserRequestSignal cancelBlockUserWithArg:[model mj_keyValues]];
}

- (RACSignal *)kickUserWithModel:(SRKickUserModel *)model {
    return [SRKickUserRequestSignal kickUserWithArg:[model mj_keyValues]];
}

- (RACSignal *)adminUserWithModel:(SRAdminSetModel *)model {
    return [SRAdminSetRequestSignal adminSetWithArg:[model mj_keyValues]];
}

- (RACSignal *)adminCancelUserWithModel:(SRAdminCancelModel *)model {
    return [SRAdminCancelRequestSignal adminCancelWithArg:[model mj_keyValues]];
}

- (RACSignal *)getOnlineNumWithRoomId:(NSString *)roomId {
    return [SROnlineNumSignal onlineNumWithRoomId:roomId];
}

- (RACSignal *)getOnlineListWithModel:(SROnlineListReqModel *)model {
    return [SROnlineListSignal onlineListWithArg:[model mj_keyValues]];
}

- (RACSignal *)modifyPassword:(SRModifyPasswordModel *)model {
    return [SRModifyPasswordRequestSignal modifyPassword:[model mj_keyValues]];
}

- (void)updateConfigWithModel:(SNConfigModel *)model {
    self.configModel = model;
}

@end
