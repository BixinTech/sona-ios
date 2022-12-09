//
//  SRGenUserSigSignal.m
//  SonaRoom
//
//  Created by Insomnia on 2020/4/17.
//

#import "SRGenUserSigSignal.h"
#import "SRRequestClient.h"

@implementation SRGenUserSigSignal

+ (RACSignal *)genUserSignalWith:(NSDictionary *)dic {
    SRRequest *request = [[SRRequest alloc] initWithMethod:SNRequestMethodGET];
    request.url = @"/sona/room/stream/gen/userSig";
    request.resClass = [SRGenUserSigResModel class];
    request.arg = dic;
    return [[SRRequestClient shareInstance] signalWithRequest:request];
}

@end
