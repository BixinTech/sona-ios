//
//  SRGenUserSigSignal.h
//  SonaRoom
//
//  Created by Insomnia on 2020/4/17.
//

#import <Foundation/Foundation.h>
#import "SRGenUserSigResModel.h"

@class RACSignal;
NS_ASSUME_NONNULL_BEGIN
@interface SRGenUserSigSignal : NSObject
+ (RACSignal *)genUserSignalWith:(NSDictionary *)dic;
@end
NS_ASSUME_NONNULL_END
