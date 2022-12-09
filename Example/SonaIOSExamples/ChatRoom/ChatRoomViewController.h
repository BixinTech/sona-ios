//
//  ChatRoomViewController.h
//  SonaIOSExamples
//
//  Created by Ju Liaoyuan on 2022/11/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChatRoomViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSString *roomTitle;
@property (nonatomic, copy) NSString *roomId;

@end

NS_ASSUME_NONNULL_END
