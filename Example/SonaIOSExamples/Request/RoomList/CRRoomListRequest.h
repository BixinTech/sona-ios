//
//  CRRoomListRequest.h
//  SonaIOSExamples
//
//  Created by Ju Liaoyuan on 2022/11/14.
//

#import "CRRequest.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "CRRoomListModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CRRoomListRequest : CRRequest

+ (RACSignal *)fetchList;

@end

NS_ASSUME_NONNULL_END
