//
//  SRRequestClient.m
//  SonaRoom
//
//  Created by Insomnia on 2020/1/14.
//

#import "SRRequestClient.h"
#import "MJExtension.h"
#import "NSDictionary+SNProtectedKeyValue.h"
#import "AFNetworking.h"
#import "SNConfigurator.h"

static NSString * const SRRequestErrorDoamin = @"SRRequest";
static const NSInteger SRRequestSuccessCode = 8000;

@interface SRRequest()

@property(nonatomic, assign) SNRequestMethod reqMethod;

@end

@implementation SRRequest

- (instancetype)initWithMethod:(SNRequestMethod)method {
    self = [super init];
    if (self) {
        self.reqMethod = method;
    }
    return self;
}

- (NSDictionary *)parameters {
    if (!self.arg) {
        return self.arg;
    }
    if ([self.arg isKindOfClass:[NSDictionary class]]) {
        return self.arg;
    } else {
        return [self.arg mj_keyValues];
    }
}

- (Class)returnType {
    return self.resClass;
}
@end


@interface SRRequestClient ()

@property (nonatomic, strong) AFHTTPSessionManager *manager;

@property (nonatomic, strong) AFJSONResponseSerializer *jsonResponseSerializer;

@property (nonatomic, strong) dispatch_queue_t completionQueue;

@end

@implementation SRRequestClient

+ (instancetype)shareInstance {
    static SRRequestClient *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[SRRequestClient alloc] _init];
    });
    return shareInstance;
}

- (instancetype)_init {
    self = [super init];
    if (self) {
        [self setupHTTPRequestManager];
    }
    return self;
}

- (void)setupHTTPRequestManager {
    _manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    _manager.securityPolicy = [AFSecurityPolicy defaultPolicy];
    
    
    _completionQueue = dispatch_queue_create("com.sona.network", DISPATCH_QUEUE_CONCURRENT);
    _manager.completionQueue = _completionQueue;
    
    AFJSONResponseSerializer *jsonResponseSerializer = [AFJSONResponseSerializer serializer];
    jsonResponseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/x-gzip",
                                                                           @"application/json",
                                                                           @"text/plain",
                                                                           @"text/javascript",
                                                                           @"text/json",
                                                                           @"text/html",
                                                                           @"text/css",
                                                                           nil];
    _manager.responseSerializer = jsonResponseSerializer;
}

- (NSURL *)baseURL {
    return [NSURL URLWithString:[SNConfigurator configurator].requestAddress];
}

- (NSString *)buildRequestURLString:(SRRequest *)request {
    NSURL *baseUrl = nil;
    if (request.baseUrl && request.baseUrl.length > 0) {
        baseUrl = [NSURL URLWithString:request.baseUrl];
    } else {
        baseUrl = [self baseURL];
    }
    return [NSURL URLWithString:request.url relativeToURL:baseUrl].absoluteString;
}

- (RACSignal *)signalWithRequest:(SRRequest *)request {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        @strongify(self)
        if (!self) {
            [subscriber sendCompleted];
            return nil;
        }
        NSString *requestMethod = nil;
        switch (request.reqMethod) {
            case SNRequestMethodGET:
                requestMethod = @"GET";
                break;
            case SNRequestMethodPOST:
                requestMethod = @"POST";
                break;
        }
        if (!requestMethod) {
            NSError *err = [NSError errorWithDomain:SRRequestErrorDoamin
                                               code:-1
                                           userInfo:@{NSLocalizedDescriptionKey: @"request method is nil"}];
            [subscriber sendError:err];
            [subscriber sendCompleted];
            return nil;
        }
        NSString *url = [self buildRequestURLString:request];
        
        NSMutableURLRequest *urlReq = [[AFJSONRequestSerializer serializer] requestWithMethod:requestMethod
                                                                                    URLString:url
                                                                                   parameters:[request parameters]
                                                                                        error:nil];
        [urlReq setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"content-type"];
        
        
        
        NSURLSessionDataTask *dataTask = [self.manager dataTaskWithRequest:urlReq
                                                            uploadProgress:nil
                                                          downloadProgress:nil
                                                         completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            if (error) {
                [subscriber sendError:error];
                [subscriber sendCompleted];
                return;
            } else {
                if (![responseObject isKindOfClass:NSDictionary.class]) {
                    return;
                }
                if ([responseObject[@"code"] intValue] != SRRequestSuccessCode) {
                    NSError *err = [NSError errorWithDomain:SRRequestErrorDoamin
                                                       code:-1
                                                   userInfo:@{NSLocalizedDescriptionKey: responseObject[@"msg"] ? : @"unknown error"}];
                    [subscriber sendError:err];
                    [subscriber sendCompleted];
                    return;
                }
                id responseResult = responseObject[@"result"];
                id result = nil;
                Class cls = request.resClass;
                if (request.isReturnArray) {
                    if ([responseResult isKindOfClass:[NSArray class]]) {
                        NSMutableArray *elements = [NSMutableArray new];
                        for (id element in responseResult) {
                            if (![element isEqual:[NSNull null]]) {
                                [elements addObject:element];
                            }
                        }
                        result = [cls mj_objectArrayWithKeyValuesArray:elements];
                    }
                } else {
                    if ([cls isEqual:[NSNumber class]]) {
                        BOOL legal = [responseResult isKindOfClass:[NSNumber class]] || [responseResult isKindOfClass:[NSString class]];
                         result = legal ? @([result boolValue]) : nil;
                    } else if ([cls isEqual:[NSString class]]) {
                        result = [responseResult isKindOfClass:[NSString class]] ? responseResult : @"";
                    } else {
                        if (![responseResult isKindOfClass:[NSDictionary class]]) {
                            result = [cls new];
                        } else {
                            if ([cls isEqual:[NSDictionary class]]) {
                                result = responseResult;
                            } else {
                                result = [cls mj_objectWithKeyValues:responseResult];
                            }
                        }
                    }
                }
                [subscriber sendNext:result];
            }
            [subscriber sendCompleted];
        }];
        [dataTask resume];
        return nil;
    }];
}


@end
