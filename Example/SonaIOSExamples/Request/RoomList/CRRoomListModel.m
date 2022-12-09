//
//  CRRoomListModel.m
//  SonaIOSExamples
//
//  Created by Ju Liaoyuan on 2022/11/14.
//

#import "CRRoomListModel.h"

@implementation CRRoomListItem

@end

@implementation CRRoomListModel


+ (NSDictionary *)mj_objectClassInArray {
    return @{
        @"list": [CRRoomListItem class]
    };
}

@end
