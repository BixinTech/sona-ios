//
//  SRRoomAdmin.h
//  SonaRoom
//
//  Created by Insomnia on 2019/12/9.
//

#import <Foundation/Foundation.h>
#import "ReactiveCocoa.h"
#import "SRCloseRoomModel.h"
#import "SRMuteMsgUserModel.h"
#import "SRMuteMsgCancelUserModel.h"
#import "SRBlockUserModel.h"
#import "SRBlockCancelUserModel.h"
#import "SRKickUserModel.h"
#import "SRAdminSetModel.h"
#import "SRAdminCancelModel.h"
#import "SROnlineListReqModel.h"
#import "SROnlineListResModel.h"
#import "SRModifyPasswordModel.h"
#import "SRCode.h"

@class SNConfigModel;

NS_ASSUME_NONNULL_BEGIN

@interface SRRoomAdmin : NSObject
- (instancetype)initWithTuple:(RACTuple *)tuple;

/**
 * 禁止用户发消息
 * @param model 参数model
 */
- (RACSignal *)muteMsgUserWithModel:(SRMuteMsgUserModel *)model;

/**
 * 取消禁止用户发消息
 * @param model 参数model
 */
- (RACSignal *)muteMsgCancelUserWithModel:(SRMuteMsgCancelUserModel *)model;

/**
 * 拉黑用户
 * @param model 参数model
 */
- (RACSignal *)blockUserWithModel:(SRBlockUserModel *)model;

/**
 * 取消拉黑
 * @param model 参数model
 */
- (RACSignal *)blockCancelUserWithModel:(SRBlockCancelUserModel *)model;

/**
 * 从房间内踢出用户
 * @param model 参数model
 */
- (RACSignal *)kickUserWithModel:(SRKickUserModel *)model;

/**
 * 添加用户管理权限
 * @param model 参数model
 */
- (RACSignal *)adminUserWithModel:(SRAdminSetModel *)model;

/**
 * 取消用户管理权限
 * @param model 参数model
 */
- (RACSignal *)adminCancelUserWithModel:(SRAdminCancelModel *)model;

/**
 * 获取房间内人数
 * @param roomId 房间 Id
 * @return integer
*/
- (RACSignal *)getOnlineNumWithRoomId:(NSString *)roomId;

/**
* 获取房间人员列表
* @param model 参数model
* @return SROnlineListResItemModel 成员列表模型
*/
- (RACSignal *)getOnlineListWithModel:(SROnlineListReqModel *)model;

/** 修改房间密码
 @param model 参数 model
 @return true or false
 */
- (RACSignal *)modifyPassword:(SRModifyPasswordModel *)model;

/**
 * 更新配置
 */
- (void)updateConfigWithModel:(SNConfigModel *)model;

@end

NS_ASSUME_NONNULL_END
