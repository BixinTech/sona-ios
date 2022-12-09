//
//  CRRoomInfoResult.m
//  SonaIOSExamples
//
//  Created by Ju Liaoyuan on 2022/11/14.
//

#import "CRRoomInfoResult.h"
#import "MJExtension.h"

@implementation CRRoomInfoSeatModel

@end

@implementation CRRoomInfoResult

+ (NSDictionary *)mj_objectClassInArray {
    return @{
        @"seatList": [CRRoomInfoSeatModel class]
    };
}

@end
