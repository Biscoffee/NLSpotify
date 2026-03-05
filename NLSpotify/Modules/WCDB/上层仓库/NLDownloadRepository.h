//
//  NLDownloadRepository.h
//  NLSpotify
//

#import <Foundation/Foundation.h>

@class NLDownloadItem, NLSong;

NS_ASSUME_NONNULL_BEGIN

@interface NLDownloadRepository : NSObject

/// 安全地创建下载表（如不存在则创建）。
+ (void)safeCreateTable;

/// 查询所有下载记录，按 addedTime 从新到旧排序。
/// - Returns: 下载项数组。
+ (NSArray<NLDownloadItem *> *)allDownloadItems;

/// 根据歌曲 ID 查询对应的下载记录。
/// - Parameter songId: 歌曲唯一标识。
/// - Returns: 若存在则为对应的下载项，否则为 `nil`。
+ (nullable NLDownloadItem *)downloadItemForSongId:(NSString *)songId;

/// 新增一条下载记录。
/// - Parameters:
///   - song: 关联的歌曲模型。
///   - status: 初始下载状态。
/// - Returns: 插入是否成功。
+ (BOOL)addDownloadItemWithSong:(NLSong *)song status:(NSString *)status;
/// 更新指定歌曲的下载状态。
/// - Parameters:
///   - status: 新的状态字符串。
///   - songId: 歌曲唯一标识。
/// - Returns: 更新是否成功。
+ (BOOL)updateStatus:(NSString *)status forSongId:(NSString *)songId;

/// 删除指定歌曲的下载记录。
/// - Parameter songId: 歌曲唯一标识。
/// - Returns: 删除是否成功。
+ (BOOL)removeDownloadItemWithSongId:(NSString *)songId;
/// 清空所有下载记录。
+ (void)clearAllDownloadItems;

@end

NS_ASSUME_NONNULL_END
