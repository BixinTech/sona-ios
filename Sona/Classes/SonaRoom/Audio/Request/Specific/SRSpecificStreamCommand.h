//
//  SRSpecificStreamCommand.h
//  SonaRoom
//
//  Created by Insomnia on 2019/12/24.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "SRSpecificStreamModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SRSpecificStreamCommand : NSObject
@property (strong, nonatomic) RACCommand *requestCommond;
@end

NS_ASSUME_NONNULL_END
