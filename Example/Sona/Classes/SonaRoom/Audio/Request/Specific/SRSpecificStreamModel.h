//
//  SRSpecificStreamModel.h
//  SonaRoom
//
//  Created by Insomnia on 2019/12/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SRSpecificStreamModel : NSObject
@property (nonatomic, copy) NSString *roomId;
@property(nonatomic, copy) NSArray <NSString *> *targetUids;
@property(nonatomic, copy) NSArray <NSString *> *sourceUids;
@end

NS_ASSUME_NONNULL_END
