//
//  SRGenUserSigResModel.h
//  SonaRoom
//
//  Created by Insomnia on 2020/4/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SRGenUserSigResModel : NSObject
@property(nonatomic, assign) NSInteger appId;
@property(nonatomic, copy) NSString *appSign;
@end

NS_ASSUME_NONNULL_END
