//
//  SRMuteStreamUserModel.h
//  SonaRoom
//
//  Created by Insomnia on 2019/12/21.
//

#import <Foundation/Foundation.h>
#import "SRBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SRMuteStreamUserModel : SRBaseModel
@property(nonatomic, copy) NSArray <NSString*>*targetUids;
@end

NS_ASSUME_NONNULL_END
