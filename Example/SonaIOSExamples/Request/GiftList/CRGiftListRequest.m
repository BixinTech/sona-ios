//
//  CRGiftListRequest.m
//  SonaIOSExamples
//
//  Created by Ju Liaoyuan on 2022/11/14.
//

#import "CRGiftListRequest.h"
#import "CRGiftModel.h"

@implementation CRGiftListRequest

+ (RACSignal *)fetchGiftList {
    CRRequest *req = [[CRRequest alloc] initWithMethod:SNRequestMethodGET];
    req.url = @"/sona/demo/gift/list";
    req.isReturnArray = true;
    req.resClass = [CRGiftModel class];
    return [[SRRequestClient shareInstance] signalWithRequest:req];
}


@end
