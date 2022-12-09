//
//  SROnlineListModel.h
//  SonaRoom
//
//  Created by Insomnia on 2019/12/28.
//

#import <Foundation/Foundation.h>
#import "SRBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SROnlineListReqModel : SRBaseModel
@property(nonatomic, copy) NSString *anchor;
@property(nonatomic, assign) NSInteger limit;
@end

NS_ASSUME_NONNULL_END
