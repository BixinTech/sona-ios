//
//  SRModifyPasswordModel.h
//  Sona
//
//  Created by Ju Liaoyuan on 2022/10/19.
//

#import "SRBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SRModifyPasswordModel : SRBaseModel;

@property (nonatomic, copy) NSString *oldPassword;

@property (nonatomic, copy) NSString *password;

@end

NS_ASSUME_NONNULL_END
