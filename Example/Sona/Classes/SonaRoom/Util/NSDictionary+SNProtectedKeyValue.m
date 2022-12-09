//
//  NSDictionary+SNProtectedKeyValue.m
//  SonaRoom
//
//  created by Insomnia on 2020/2/8.
//

#import "NSDictionary+SNProtectedKeyValue.h"

@implementation NSDictionary (SNProtectedKeyValue)
- (BOOL)snBoolForKey:(NSString *)key {
    if (!key.length) return NO;
    BOOL b = NO;
    NSString *value = [self objectForKey:key];
    if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
        b = [value boolValue];
    }
    return b;
}

- (NSInteger)snIntegerForKey:(NSString *)key {
    if (!key.length) return 0;
    NSInteger i = 0;
    NSString *value = [self objectForKey:key];
    if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
        i = [value integerValue];
    }
    return i;
}

- (NSDictionary *)snDicForKey:(NSString *)key {
    if (!key.length) return @{};
    NSDictionary *result = @{};
    NSDictionary *dic = [self objectForKey:key];
    if ([dic isKindOfClass:[NSDictionary class]]) {
           result = dic;
    }
    return result;
}

- (NSString *)snStringForKey:(NSString *)key {
    if (!key.length) return @"";
    NSString *result = @"";
    NSString *value = [self objectForKey:key];
    if ([value isKindOfClass:[NSString class]]) {
        result = value;
    }else if ([value isKindOfClass:[NSNumber class]]) {
        result = [NSString stringWithFormat:@"%@", value];
    }
    return result;
}

- (NSArray *)snArrayForKey:(NSString *)key {
    if (!key.length) return @[];
    NSArray *result = @[];
    NSArray *value = [self objectForKey:key];
    if ([value isKindOfClass:[NSArray class]]) {
        result = value;
    }
    return result;
}

@end
