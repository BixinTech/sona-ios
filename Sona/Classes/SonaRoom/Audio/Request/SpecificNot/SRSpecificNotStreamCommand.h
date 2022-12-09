//
//  SRSpecificNotStreamCommand.h
//  SonaRoom
//
//  Created by Insomnia on 2019/12/25.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "SRSpecificNotStreamModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SRSpecificNotStreamCommand : NSObject
@property (strong, nonatomic) RACCommand *requestCommond;
@end

NS_ASSUME_NONNULL_END
