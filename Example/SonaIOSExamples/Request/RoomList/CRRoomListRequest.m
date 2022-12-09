//
//  CRRoomListRequest.m
//  SonaIOSExamples
//
//  Created by Ju Liaoyuan on 2022/11/14.
//

#import "CRRoomListRequest.h"
#import "CRRoomListModel.h"

@implementation CRRoomListRequest

+ (RACSignal *)fetchList {
    CRRequest *req = [[CRRequest alloc] initWithMethod:SNRequestMethodGET];
    req.url = @"/sona/demo/room/list";
    req.resClass = CRRoomListItem.class;
    req.isReturnArray = true;
    return [[SRRequestClient shareInstance] signalWithRequest:req];
}


@end
