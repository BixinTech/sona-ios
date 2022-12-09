//
//  SREnterRoomModel.h
//  SonaRoom
//
//  Created by Insomnia on 2019/12/9.
//

#import <Foundation/Foundation.h>
#import "SRBaseModel.h"

NS_ASSUME_NONNULL_BEGIN


/// base model @see SRBaseModel
@interface SREnterRoomModel : SRBaseModel

@property (nonatomic, copy) NSString *productCode;

@property (nonatomic, copy) NSString *password;

@property (nonatomic, copy) NSDictionary *extMap;

@end

NS_ASSUME_NONNULL_END
