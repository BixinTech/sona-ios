//
//  SROnlineListResModel.h
//  SonaRoom
//
//  Created by Insomnia on 2019/12/30.
//

#import <Foundation/Foundation.h>
#import "SRBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SROnlineListRole) {
    SROnlineListRoleMember = 0,
    SROnlineListRoleAdmin = 4,
    SROnlineListRoleHost = 5
};

@interface SROnlineListResItemModel : SRBaseModel
@property(nonatomic, assign) SROnlineListRole role;
@end

@interface SROnlineListResModel : SRBaseModel
@property(nonatomic, copy) NSString *anchor;
@property(nonatomic, assign) NSUInteger count;
@property(nonatomic, assign) NSUInteger emptyMsg;
@property(nonatomic, assign) NSUInteger end;
@property(nonatomic, strong) NSArray <SROnlineListResItemModel *> *list;
@end

NS_ASSUME_NONNULL_END
