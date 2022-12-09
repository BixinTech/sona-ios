//
//  SRMsgSendRequestSignal.m
//  SonaRoom
//
//  Created by Insomnia on 2020/1/16.
//

#import "SRMsgSendRequestSignal.h"
#import "NSDictionary+SNProtectedKeyValue.h"
#import "MJExtension.h"
#import "SRCode.h"
#import "SRMessageCodec.h"

@implementation SRMsgSendRequestSignal
+ (RACSignal *)msgSendWithModel:(SRMsgSendModel *)model roomId:(NSString *)roomId {
    SRRequest *request = [[SRRequest alloc] initWithMethod:SNRequestMethodPOST];
    request.url = @"/sona/msg/send";

    NSDictionary *args = [SRMessageCodec encodeWithModel:model];
    if (model.msgFormat == SRMsgFormatTransparent || model.msgFormat == SRMsgFormatAck) {
        request.arg = args;
        return [[SRRequestClient shareInstance] signalWithRequest:request];
    } else if (model.msgFormat == SRMsgFormatText || model.msgFormat == SRMsgFormatEmoji) {
        if (![model.content isKindOfClass:[NSString class]]) {
            NSAssert(NO, @"Should be string");
            return [RACSignal error:[NSError errorWithDomain:SRErrorDomain code:-1 userInfo:nil]];
        }
        request.arg = args;
        return [[SRRequestClient shareInstance] signalWithRequest:request];
    } else {
        if (![model.content isKindOfClass:[NSData class]]) {
            NSAssert(NO, @"Should be data");
            return [RACSignal error:[NSError errorWithDomain:SRErrorDomain code:-1 userInfo:nil]];
        }
        NSInteger fileType = 0;
        switch (model.msgFormat) {
            case SRMsgFormatImage:
//                fileType = Image;
                break;
            case SRMsgFormatAudio:
//                fileType = Audio;
                break;
            case SRMsgFormatVideo:
//                fileType = Video;
                break;
            default:
                fileType = 0;
                break;
        }
        if (1) {
//            return [[YppUploadManager uploadData:model.message businessType:YppMediaBusinessBXIm fileType:fileType] flattenMap:^RACStream *(NSDictionary *res) {
//                model.message = [res snStringForKey:@"key"];
//                NSMutableDictionary *mediaArgDic = [model mj_keyValues];
//                [mediaArgDic setValue:[model.attach mj_JSONString] forKey:@"attach"];
//                [mediaArgDic setValue:[res mj_JSONString] forKey:@"mediaInfo"];
//                [mediaArgDic setValue:roomId forKey:@"roomId"];
//                request.arg = mediaArgDic;
//
                return [[SRRequestClient shareInstance] signalWithRequest:request];
//            }];
        } else {
            return [RACSignal error:[NSError errorWithDomain:SRErrorDomain code:-1 userInfo:nil]];
        }
    }
}

@end
