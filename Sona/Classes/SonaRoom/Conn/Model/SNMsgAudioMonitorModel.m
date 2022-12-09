//
//  SNMsgAudioMonitorModel.m
//  SonaRoom
//
//  Created by Insomnia on 2020/8/10.
//

#import "SNMsgAudioMonitorModel.h"
#import "MJExtension.h"

@implementation SNMsgAudioMonitorModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{
        @"streamIds" : [NSString class],
    };
}

@end
