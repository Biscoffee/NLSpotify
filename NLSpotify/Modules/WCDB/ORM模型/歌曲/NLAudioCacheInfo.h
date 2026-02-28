//
//  NLAudioCacheInfo.h
//  NLSpotify
//
//  Created by 吴桐 on 2026/2/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NLAudioCacheInfo : NSObject

/// 1. 唯一标识：音频 URL 的 MD5 值 (也是本地沙盒中的文件名)
@property (nonatomic, copy) NSString *urlMD5;

/// 2. 文件总大小：即 Content-Range 里的真实完整大小
@property (nonatomic, assign) long long totalLength;

/// 3. 已缓存的区间 (Range) 集合：
/// 极其关键！这里存一个 JSON 字符串，例如："[{\"loc\":0, \"len\":10000}, {\"loc\":50000, \"len\":8000}]"
/// 我们后续会在内存里把它转成 NSArray<NSValue *>，写入数据库时再转成 NSString
@property (nonatomic, copy) NSString *cachedRangesString;

/// 4. 最后一次访问时间：用于触发 LRU 淘汰算法，毫秒级时间戳
@property (nonatomic, assign) NSTimeInterval lastAccessTime;

/// 5. 辅助字段：当前是否 100% 缓存完毕 (0: 下载中, 1: 已完成)
@property (nonatomic, assign) BOOL isFinished;

@end

NS_ASSUME_NONNULL_END
