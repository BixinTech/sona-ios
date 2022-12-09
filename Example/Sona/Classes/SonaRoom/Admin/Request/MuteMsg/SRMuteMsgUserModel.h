//
//  SRMuteMsgUserModel.h
//  SonaRoom
//
//  Created by Insomnia on 2019/12/17.
//

#import <Foundation/Foundation.h>
#import "SRBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SRMuteMsgUserModel : SRBaseModel
/** 禁言用户uid  */
@property(nonatomic, copy) NSString *targetUid;
/** 禁言用户时间, 单位分钟, 填0为永久禁言,  */
@property(nonatomic, assign) NSUInteger minute;
@end

NS_ASSUME_NONNULL_END
