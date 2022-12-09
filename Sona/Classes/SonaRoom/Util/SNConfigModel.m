//
//  SNConfigModel.m
//  SonaSDK
//
//  Created by Insomnia on 2019/12/3.
//

#import "SNConfigModel.h"

@implementation SNConnConfigModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{
        @"imTypeList": [NSDictionary class],
    };
}


@end

@implementation SNStreamConfigModel
+ (NSDictionary *)mj_objectClassInArray {
    return @{
        @"streamList": [NSString class],
    };
}

- (NSString *)streamUrl {
    return _streamUrl ? : @"";
}

@end


@implementation SNProductConfigModel
+ (NSDictionary *)mj_objectClassInArray {
    return @{
            @"imConfig": [SNConnConfigModel class],
            @"streamConfig": [SNStreamConfigModel class],
    };
}
@end

@implementation SNConfigModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{
            @"productConfig": [SNProductConfigModel class]
    };
}

- (NSMutableDictionary *)attMDic {
    if (!_attMDic) {
        _attMDic = [NSMutableDictionary new];
    }
    return _attMDic;
}

- (NSString *)roomId {
    return _roomId ? : @"";
}

@end
