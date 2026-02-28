//
//  NLResourceLoader.h
//  NLSpotify
//
//  Created by 吴桐 on 2026/2/26.
//

#import "AVFoundation/AVFoundation.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NLResourceLoader : NSObject<AVAssetResourceLoaderDelegate>
@property (nonatomic, strong) NSURL *originURL;

/// 切歌或 Loader 废弃前调用，断开 session 强引用链，避免循环引用
- (void)invalidateSession;
- (void)invalidateAndCancelAll;

@end

NS_ASSUME_NONNULL_END
