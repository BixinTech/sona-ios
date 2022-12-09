//
//  SNThreadSafeSet.m
//  SonaAudio
//
//  Created by Ju Liaoyuan on 2022/3/8.
//

#import "SNThreadSafeSet.h"

#define INIT(...) self = super.init; \
if (!self) return nil; \
__VA_ARGS__; \
if (!_set) return nil; \
_lock = dispatch_semaphore_create(1); \
return self;


#define LOCK(...) dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER); \
__VA_ARGS__; \
dispatch_semaphore_signal(_lock);

@implementation SNThreadSafeSet {
    NSMutableSet *_set;  //Subclass a class cluster...
    dispatch_semaphore_t _lock;
}

#pragma mark - init

- (instancetype)init {
    INIT(_set = [NSMutableSet new]);
}

- (instancetype)initWithCapacity:(NSUInteger)numItems {
    INIT(_set = [[NSMutableSet alloc] initWithCapacity:numItems]);
}

- (instancetype)initWithArray:(NSArray *)array {
    INIT(_set = [[NSMutableSet alloc] initWithArray:array]);
}

- (instancetype)initWithObjects:(id  _Nonnull const [])objects count:(NSUInteger)cnt {
    INIT(_set = [[NSMutableSet alloc] initWithObjects:objects count:cnt]);
}

- (instancetype)initWithSet:(NSSet *)set {
    INIT(_set = [[NSMutableSet alloc] initWithSet:set]);
}

- (instancetype)initWithSet:(NSSet *)set copyItems:(BOOL)flag {
    INIT(_set = [[NSMutableSet alloc] initWithSet:set copyItems:flag]);
}

#pragma mark - method

- (NSUInteger)count {
    LOCK(NSUInteger c = _set.count); return c;
}

- (void)addObject:(id)object {
    LOCK([_set addObject:object]);
}

- (BOOL)containsObject:(id)anObject {
    LOCK(BOOL ret = [_set containsObject:anObject]);
    return ret;
}

- (id)anyObject {
    LOCK(id obj = [_set anyObject]);
    return obj;
}

- (void)removeObject:(id)object {
    LOCK([_set removeObject:object]);
}

- (void)removeAllObjects {
    LOCK([_set removeAllObjects]);
}

- (NSArray *)allObjects {
    LOCK(NSArray *ret = [_set allObjects]);
    return ret;
}

- (void)addObjectsFromArray:(NSArray *)array {
    LOCK([_set addObjectsFromArray:array]);
}
- (void)intersectSet:(NSSet *)otherSet {
    LOCK([_set intersectSet:otherSet]);
}
- (void)minusSet:(NSSet *)otherSet {
    LOCK([_set minusSet:otherSet]);
}

- (void)unionSet:(NSSet *)otherSet {
    LOCK([_set unionSet:otherSet]);
}

- (void)setSet:(NSSet *)otherSet {
    LOCK([_set setSet:otherSet]);
}

- (BOOL)isEqualToSet:(NSSet *)otherSet {
    if (otherSet == self) return YES;
    
    if ([otherSet isKindOfClass:SNThreadSafeSet.class]) {
        SNThreadSafeSet *other = (id)otherSet;
        BOOL isEqual;
        dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
        dispatch_semaphore_wait(other->_lock, DISPATCH_TIME_FOREVER);
        isEqual = [_set isEqualToSet:other->_set];
        dispatch_semaphore_signal(other->_lock);
        dispatch_semaphore_signal(_lock);
        return isEqual;
    }
    return NO;
}

- (BOOL)isEqual:(id)object {
    if (object == self) return YES;
    
    if ([object isKindOfClass:SNThreadSafeSet.class]) {
        SNThreadSafeSet *other = object;
        BOOL isEqual;
        dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
        dispatch_semaphore_wait(other->_lock, DISPATCH_TIME_FOREVER);
        isEqual = [_set isEqual:other->_set];
        dispatch_semaphore_signal(other->_lock);
        dispatch_semaphore_signal(_lock);
        return isEqual;
    }
    return NO;
}

- (id)copyWithZone:(NSZone *)zone {
    return [self mutableCopyWithZone:zone];
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    LOCK(id copiedSet = [[self.class allocWithZone:zone] initWithSet:_set]);
    return copiedSet;
}

- (NSUInteger)hash {
    LOCK(NSUInteger hash = [_set hash]);
    return hash;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(__unsafe_unretained id  _Nullable [])buffer
                                    count:(NSUInteger)len {
    LOCK(NSUInteger count = [_set countByEnumeratingWithState:state objects:buffer count:len]);
    return count;
}

- (void)enumerateObjectsUsingBlock:(void (NS_NOESCAPE ^)(id _Nonnull, BOOL * _Nonnull))block {
    LOCK([_set enumerateObjectsUsingBlock:block]);
}

- (void)enumerateObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (NS_NOESCAPE ^)(id _Nonnull, BOOL * _Nonnull))block {
    LOCK([_set enumerateObjectsWithOptions:opts usingBlock:block]);
}

- (NSEnumerator *)objectEnumerator {
    LOCK(NSEnumerator *e = [_set objectEnumerator]);
    return e;
}

- (NSString *)description {
    LOCK(NSString *desc = [_set description]);
    return desc;
}

- (NSString *)descriptionWithLocale:(id)locale {
    LOCK(NSString *desc = [_set descriptionWithLocale:locale]);
    return desc;
}

@end
