//
//  SNConfigModel.h
//  SonaSDK
//
//  Created by Insomnia on 2019/12/3.
//

#import <Foundation/Foundation.h>
#import "SNModel.h"

NS_ASSUME_NONNULL_BEGIN

#define SN_CONN_MODULE_GAME @"GAME"
#define SN_CONN_MODULE_CHATROOM @"CHATROOM"

#define SN_STREAM_PULL_MODE_MULTI @"MULTI"
#define SN_STREAM_PULL_MODE_MIXED @"MIXED"

#define SN_STREAM_PUSH_MODE_MIXED @"MIXED"
#define SN_STREAM_PUSH_MODE_MULTI @"MULTI"

#define SN_STREAM_SUPPLIER_ZEGO @"ZEGO"
#define SN_STREAM_SUPPLIER_TENCENT @"TENCENT"
#define SN_STREAM_SUPPLIER_QINIU @"QINIU"

@interface SNConnConfigModel : SNModel

@property(nonatomic, strong) NSString *module;

@property (nonatomic, assign) NSInteger clientQueueSize;

@property (nonatomic, assign) NSInteger messageExpireTime;

@property (nonatomic, assign) BOOL arrivalMessageSwitch;

/**
 * 1: 短链(http)
 * 2: 长链
 */
@property (nonatomic, assign) NSInteger imSendType;

@end


@interface SNStreamConfigModel : SNModel

@property(nonatomic, strong) NSString *pullMode;

@property(nonatomic, strong) NSString *pushMode;

@property(nonatomic, copy) NSArray <NSString *> *streamList;

@property(nonatomic, copy) NSString *streamUrl;

@property(nonatomic, copy) NSString *streamId;

@property(nonatomic, strong) NSString *supplier;

@property(nonatomic, strong) NSString *type;

//默认 0 扬声器：1
@property(nonatomic, strong) NSString *switchSpeaker;

@property(nonatomic, copy) NSString *audioToken;

@property(nonatomic, copy) NSDictionary *streamRoomId;

@property(nonatomic, copy) NSDictionary *appInfo;

@property (nonatomic, assign) NSInteger bitrate;

@end


@interface SNProductConfigModel: SNModel

@property(nonatomic, copy) NSString *productCode;

@property(nonatomic, copy) NSString *productCodeAlias;

@property(nonatomic, strong) SNConnConfigModel *imConfig;

@property(nonatomic, strong) SNStreamConfigModel *streamConfig;

@end


@interface SNConfigModel : SNModel

@property(nonatomic, strong) SNProductConfigModel *productConfig;

@property (nonatomic, copy) NSString *roomId;

@property(nonatomic, copy) NSString *guestUid;

@property(nonatomic, copy) NSString *addr;

@property(nonatomic, copy) NSDictionary *extra;

@property (nonatomic, copy) NSString *nickname;

@property (nonatomic, assign) BOOL micEnabled;

@property(nonatomic, strong) NSMutableDictionary *attMDic;

/// local
@property (nonatomic, copy) NSString *uid;

@end

NS_ASSUME_NONNULL_END
