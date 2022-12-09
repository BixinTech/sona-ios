//
//  SRMuteStreamCancelUserCommand.h
//  SonaRoom
//
//  Created by Insomnia on 2019/12/21.
//

#import <Foundation/Foundation.h>
#import "ReactiveCocoa.h"
#import "SRUnMuteStreamUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SRUnMuteStreamUserCommand : NSObject
@property (strong, nonatomic) RACCommand *requestCommond;
@end

NS_ASSUME_NONNULL_END
