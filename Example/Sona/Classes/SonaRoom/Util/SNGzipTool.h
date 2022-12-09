//
//  SNGzipTool.h
//  SonaRoom
//
//  Created by Ju Liaoyuan on 2022/9/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SNGzipTool : NSObject

+ (NSData *)zipData:(NSData *)pUncompressedData;  //压缩
+ (NSData *)unzipData:(NSData *)compressedData;  //解压缩

@end

NS_ASSUME_NONNULL_END
