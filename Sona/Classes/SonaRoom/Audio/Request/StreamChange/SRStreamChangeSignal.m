//
//  SRStreamChangeSignal.m
//  SonaRoom
//
//  Created by Insomnia on 2020/7/25.
//

#import "SRStreamChangeSignal.h"
#import "SRRequestClient.h"

@implementation SRStreamChangeSignal

+ (RACSignal *)streamChangeWith:(NSDictionary *)dic {
    SRRequest *request = [[SRRequest alloc] initWithMethod:SNRequestMethodPOST];
    request.url = @"/sona/stream/change";
    request.resClass = [NSNumber class];
    request.arg = dic;
    return [[SRRequestClient shareInstance] signalWithRequest:request];
}

@end
