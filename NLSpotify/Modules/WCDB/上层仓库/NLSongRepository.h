//
//  NLSongRepository.h
//  NLSpotify
//
//  Created by 吴桐 on 2026/2/23.
//

#import <Foundation/Foundation.h>

@class NLSong;

NS_ASSUME_NONNULL_BEGIN

@interface NLSongRepository : NSObject

/// 将歌曲标记为「已下载」并写入本地表。
/// - Parameter song: 下载完成的歌曲。
/// - Returns: 插入是否成功。
+ (BOOL)addDownloadedSong:(NLSong *)song;
/// 移除一条已下载歌曲记录。
/// - Parameter songId: 歌曲唯一标识。
/// - Returns: 删除是否成功。
+ (BOOL)removeDownloadedSong:(NSString *)songId;
/// 判断歌曲是否已被下载。
/// - Parameter songId: 歌曲唯一标识。
/// - Returns: 若已下载则为 YES。
+ (BOOL)isSongDownloaded:(NSString *)songId;
/// 查询所有已下载歌曲。
/// - Returns: 歌曲数组。
+ (NSArray<NLSong *> *)allDownloadedSongs;

/// 清空所有已下载歌曲记录。
+ (void)clearAllDownloadedSongs;
/// 新增一条播放历史记录。
/// - Parameter song: 刚刚播放的歌曲。
/// - Returns: 插入是否成功。
+ (BOOL)addPlayHistory:(NLSong *)song;
/// 移除指定歌曲的播放历史。
/// - Parameter songId: 歌曲唯一标识。
/// - Returns: 删除是否成功。
+ (BOOL)removePlayHistoryWithSongId:(NSString *)songId;
/// 查询所有播放历史记录。
/// - Returns: 歌曲数组，按时间从新到旧排序。
+ (NSArray<NLSong *> *)allPlayHistory;

/// 查询所有已收藏歌曲。
/// - Returns: 歌曲数组。
+ (NSArray<NLSong *> *)allLikedSongs;
/// 收藏或取消收藏一首歌曲。
/// - Parameters:
///   - song: 目标歌曲。
///   - isLike: YES 表示收藏，NO 表示取消收藏。
/// - Returns: 更新是否成功。
+ (BOOL)likeSong:(NLSong *)song isLike:(BOOL)isLike;
/// 判断歌曲是否已被收藏。
/// - Parameter songId: 歌曲唯一标识。
/// - Returns: 若已收藏则为 YES。
+ (BOOL)isSongLiked:(NSString *)songId;

@end

NS_ASSUME_NONNULL_END
