//
//  SRKickUserModel.h
//  SonaRoom
//
//  Created by Insomnia on 2019/12/17.
//

#import <Foundation/Foundation.h>
#import "SRBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SRKickUserModel : SRBaseModel
@property(nonatomic, copy) NSString *targetUid;
@end

NS_ASSUME_NONNULL_END
