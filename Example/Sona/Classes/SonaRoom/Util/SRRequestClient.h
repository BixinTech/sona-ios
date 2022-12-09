//
//  SRRequestClient.h
//  SonaRoom
//
//  Created by Insomnia on 2020/1/14.
//

#import <Foundation/Foundation.h>
#import "ReactiveCocoa.h"

NS_ASSUME_NONNULL_BEGIN

//  HTTP Request method.
typedef NS_ENUM(NSInteger, SNRequestMethod) {
    SNRequestMethodGET = 0,
    SNRequestMethodPOST
};

@interface SRRequest : NSObject

- (instancetype)initWithMethod:(SNRequestMethod)method NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@property(nonatomic, copy) NSString *url;
@property(nonatomic, strong) id arg;
@property(nonatomic, strong) Class resClass;
@property (nonatomic, copy) NSString *baseUrl;
@property (nonatomic, assign) BOOL isReturnArray;

@end

@interface SRRequestClient : NSObject

+ (id)shareInstance;

- (RACSignal *)signalWithRequest:(SRRequest *)request;

@end

NS_ASSUME_NONNULL_END
