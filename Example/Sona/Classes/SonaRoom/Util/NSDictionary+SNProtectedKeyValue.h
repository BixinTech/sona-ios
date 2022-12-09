//
//  NSDictionary+snProtectedKeyValue.h
//  SonaRoom
//
//  created by Insomnia on 2020/2/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (SNProtectedKeyValue)
- (BOOL)snBoolForKey:(NSString *)key;
- (NSInteger)snIntegerForKey:(NSString *)key;
- (NSDictionary *)snDicForKey:(NSString *)key;
- (NSString *)snStringForKey:(NSString *)key;
- (NSArray *)snArrayForKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
