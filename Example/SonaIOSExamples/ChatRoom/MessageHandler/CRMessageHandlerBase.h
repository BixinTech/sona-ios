//
//  CRMessageHandlerBase.h
//  SonaIOSExamples
//
//  Created by Ju Liaoyuan on 2022/11/24.
//

#import <Foundation/Foundation.h>
#import "CRMessageHandlerProtocol.h"
#import "ChatRoomViewController+Private.h"

NS_ASSUME_NONNULL_BEGIN

@class ChatRoomViewController;

@interface CRMessageHandlerBase : NSObject<CRMessageHandlerProtocol>

@property (nonatomic, weak) ChatRoomViewController *chatRoom;

- (instancetype)initWithChatRoomVC:(ChatRoomViewController *)vc;

@end

NS_ASSUME_NONNULL_END
