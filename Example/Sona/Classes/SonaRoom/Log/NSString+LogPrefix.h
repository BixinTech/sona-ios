//
//  NSString+LogPrefix.h
//  SonaRoom
//
//  Created by Ju Liaoyuan on 2022/2/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (LogPrefix)

- (NSString *)appendPrefix:(NSString *)prefix;

@end

NS_ASSUME_NONNULL_END
