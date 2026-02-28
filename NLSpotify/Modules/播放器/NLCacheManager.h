//
//  NLCacheManager.h
//  NLSpotify
//
//  Created by 吴桐 on 2026/2/26.
//
//  以 NLCacheManager.mm 实现为准：写缓存统一走 cacheData:forURL:atOffset:totalLength:，
//  读/查走 tempFilePathForURL、cacheFilePathForURL、cachedRangesForURL、totalLengthForURL、cacheProgressForURL、isFullyCachedForURL；
//  任务结束时 mergeAndSaveSessionRanges，若已覆盖整首再 finishCacheForURL。
//

#import <Foundation/Foundation.h>
#import "NLAudioCacheInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface NLCacheManager : NSObject

+ (instancetype)sharedManager;

#pragma mark - 路径与查询

/// 获取 URL 对应的临时文件路径 (.tmp)，未下完时使用
- (NSString *)tempFilePathForURL:(NSURL *)url;

/// 获取 URL 对应的完整缓存文件路径 (.mp3)，整首下完后使用
- (NSString *)cacheFilePathForURL:(NSURL *)url;

/// 是否已整首缓存（.mp3 文件存在）
- (BOOL)isFullyCachedForURL:(NSURL *)url;

/// 数据库中该 URL 的总长度，0 表示尚未知
- (long long)totalLengthForURL:(NSURL *)url;

/// 已缓存区间（NSValue 包装的 NSRange 数组），用于判断命中和合并
- (NSArray<NSValue *> *)cachedRangesForURL:(NSURL *)url;

/// 缓存进度 0.0 ~ 1.0（已缓存字节/总长），用于 UI 缓存条
- (float)cacheProgressForURL:(NSURL *)url;

/// 若该 URL 已整首缓存，返回其最后访问时间（毫秒时间戳），用于排序；未缓存返回 0
- (NSTimeInterval)lastAccessTimeForFullyCachedURL:(NSURL *)url;

/// 整首缓存完成时发送（userInfo[@"url"] = NSURL），用于缓存歌单实时刷新
extern NSNotificationName const NLCacheManagerDidFinishCachingNotification;

#pragma mark - 写入与完成

/// 将一段数据写入该 URL 的 .tmp 文件；内部会按需建立 DB 档案（totalLength）。ResourceLoader 收到网络数据时调用。
- (void)cacheData:(NSData *)data forURL:(NSURL *)url atOffset:(long long)offset totalLength:(long long)totalLength;

/// 任务结束：将本任务的 sessionRanges 与 DB 已有 ranges 合并后写回
- (void)mergeAndSaveSessionRanges:(NSArray<NSValue *> *)sessionRanges forURL:(NSURL *)url;

/// 已缓存区间是否覆盖 [0, totalLength)，用于决定是否可调用 finishCacheForURL
- (BOOL)cachedRangesCoverFullLengthForURL:(NSURL *)url;

/// 仅当已覆盖整首时：.tmp 重命名为 .mp3 并标记 isFinished，避免空洞导致闪退/爆音
- (void)finishCacheForURL:(NSURL *)url;

#pragma mark - 清理

/// 按 LRU 清理至不超过 maxSize。建议在 App 启动、进入后台或整首下完后调用，勿放在请求热路径
- (void)cleanCacheWithMaxSize:(long long)maxSize;

/// 清空所有缓存：删除 NLAudioCache 目录下所有文件并清空缓存账本表（用于设置内一键清空）
- (void)clearAllCache;

@end

NS_ASSUME_NONNULL_END
