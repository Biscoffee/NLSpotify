//
//  NLCacheManager.h
//  NLSpotify
//
//  Created by 吴桐 on 2026/2/26.
//
//

#import <Foundation/Foundation.h>
#import "NLAudioCacheInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface NLCacheManager : NSObject

/// 全局单例，用于管理音频缓存。
/// - Returns: 全局共享的 `NLCacheManager` 实例。
+ (instancetype)sharedManager;

/// 获取对应 URL 的临时缓存文件路径（.tmp）。
/// - Parameter url: 原始音频资源的网络地址。
/// - Returns: 当前会话对应的临时缓存文件完整路径。
- (NSString *)tempFilePathForURL:(NSURL *)url;

/// 获取对应 URL 的最终缓存文件路径（.mp3）。
/// - Parameter url: 原始音频资源的网络地址。
/// - Returns: 若整首缓存完成，则为最终缓存文件路径；否则为预期路径。
- (NSString *)cacheFilePathForURL:(NSURL *)url;

/// 是否已整首缓存（.mp3 文件存在）。
/// - Parameter url: 原始音频资源的网络地址。
/// - Returns: 若已完成整首缓存则为 YES。
- (BOOL)isFullyCachedForURL:(NSURL *)url;

/// 查询数据库中该 URL 的总长度。
/// - Parameter url: 原始音频资源的网络地址。
/// - Returns: 字节总长度，0 表示尚未知。
- (long long)totalLengthForURL:(NSURL *)url;

/// 查询该 URL 已缓存的字节区间。
/// - Parameter url: 原始音频资源的网络地址。
/// - Returns: 使用 `NSValue` 包装的 `NSRange` 数组，用于命中和区间合并。
- (NSArray<NSValue *> *)cachedRangesForURL:(NSURL *)url;

/// 计算该 URL 的缓存进度。
/// - Parameter url: 原始音频资源的网络地址。
/// - Returns: 0.0 ~ 1.0 的进度值（已缓存字节 / 总长度），用于 UI 缓存条展示。
- (float)cacheProgressForURL:(NSURL *)url;

/// 获取整首缓存文件的最后访问时间。
/// - Parameter url: 原始音频资源的网络地址。
/// - Returns: 毫秒时间戳，用于排序；若未整首缓存则返回 0。
- (NSTimeInterval)lastAccessTimeForFullyCachedURL:(NSURL *)url;

/// 整首缓存完成时发送的通知。
/// - Discussion: `userInfo[@"url"]` 为对应的 `NSURL`，用于歌单缓存状态实时刷新。
extern NSNotificationName const NLCacheManagerDidFinishCachingNotification;

#pragma mark - 写入与完成

/// 将一段数据写入该 URL 的临时缓存文件。
/// - Parameters:
///   - data: 本次写入的数据块。
///   - url: 原始音频资源的网络地址。
///   - offset: 写入的起始偏移（字节）。
///   - totalLength: 资源总长度；用于在数据库中建立或更新元数据。
/// - Discussion: 通常由 `NLResourceLoader` 在收到网络数据时调用。
- (void)cacheData:(NSData *)data forURL:(NSURL *)url atOffset:(long long)offset totalLength:(long long)totalLength;

/// 将本次会话产生的缓存区间与数据库中的区间进行合并并持久化。
/// - Parameters:
///   - sessionRanges: 当前任务产生的缓存区间（`NSValue` 包装的 `NSRange` 数组）。
///   - url: 原始音频资源的网络地址。
- (void)mergeAndSaveSessionRanges:(NSArray<NSValue *> *)sessionRanges forURL:(NSURL *)url;

/// 检查已缓存区间是否覆盖 [0, totalLength)。
/// - Parameter url: 原始音频资源的网络地址。
/// - Returns: 若可以视为整首已缓存，则为 YES。
- (BOOL)cachedRangesCoverFullLengthForURL:(NSURL *)url;

/// 将指定 URL 对应的缓存从 .tmp 转为最终 .mp3 文件。
/// - Parameter url: 原始音频资源的网络地址。
/// - Discussion: 仅在已完整覆盖整首时调用，会重命名文件并标记为已完成，避免空洞导致闪退或爆音。
- (void)finishCacheForURL:(NSURL *)url;

#pragma mark - 清理

/// 按 LRU 策略清理缓存至不超过指定大小。
/// - Parameter maxSize: 允许的最大缓存空间（字节）。
/// - Discussion: 建议在 App 启动、进入后台或整首缓存完毕后调用，避免阻塞请求热路径。
- (void)cleanCacheWithMaxSize:(long long)maxSize;

/// 清空所有缓存数据。
/// - Discussion: 会删除 `NLAudioCache` 目录下所有文件并清空缓存账本表，适合设置页的一键清空操作。
- (void)clearAllCache;

@end

NS_ASSUME_NONNULL_END
