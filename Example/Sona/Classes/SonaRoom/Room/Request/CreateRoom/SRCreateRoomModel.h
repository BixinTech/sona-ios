//
//  SRCreateRoomModel.h
//  SonaRoom
//
//  Created by Insomnia on 2019/12/6.
//

#import <Foundation/Foundation.h>
#import "SRBaseModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface SRCreateRoomModel : SRBaseModel

@property (nonatomic, copy) NSString *roomTitle;

@property (nonatomic, copy) NSString *productCode;

@property (nonatomic, copy, nullable) NSString *password;

@end

NS_ASSUME_NONNULL_END
