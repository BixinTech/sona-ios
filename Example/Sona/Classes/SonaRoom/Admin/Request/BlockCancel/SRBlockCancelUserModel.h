//
//  SRBlockCancelUserModel.h
//  SonaRoom
//
//  Created by Insomnia on 2019/12/17.
//

#import <Foundation/Foundation.h>
#import "SRBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SRBlockCancelUserModel : SRBaseModel
@property(nonatomic, copy) NSString *targetUid;
@property(nonatomic, copy) NSString *reason;
@end

NS_ASSUME_NONNULL_END
