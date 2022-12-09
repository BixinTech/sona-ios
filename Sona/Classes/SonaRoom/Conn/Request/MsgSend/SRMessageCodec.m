//
//  SRMessageCodec.m
//  SonaRoom
//
//  Created by Ju Liaoyuan on 2022/11/9.
//

#import "SRMessageCodec.h"
#import "SRMsgSendModel.h"
#import "MJExtension.h"

@implementation SRMessageCodec

+ (NSDictionary *)decodeWithData:(NSData *)data error:(NSError **)error {
    NSString *domain = @"com.sn.parseData";
    if (!data || ![data isKindOfClass:[NSData class]]) {
        *error = [NSError errorWithDomain:domain
                                     code:-100
                                 userInfo:@{NSLocalizedDescriptionKey:@"unexpected dataSource"}];
        return nil;
    }
    NSDictionary *result = nil;
    @try {
        result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:error];
    } @catch (NSException *exception) {
        *error = [NSError errorWithDomain:domain
                                     code:-101
                                 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"parse json fail, exception detail: %@, %@, %@, data length: %@", exception.name, exception.reason, exception.userInfo, @(data.length)]}];
    } @finally {}
    return result;
}


+ (NSDictionary *)encodeWithModel:(SRMsgSendModel *)model {
    if (!model) {
        return nil;
    }
    NSMutableDictionary *properties = [model mj_keyValues];
    if (!model.messageId) {
        [properties setValue:[[NSUUID UUID] UUIDString] forKey:@"messageId"];
    }
    return properties.copy;
}

@end
