//
//  NLSongRepository.mm
//  NLSpotify
//
//  Created by 吴桐 on 2026/2/23.
//

#import "NLSongRepository.h"
#import "NLDataBaseManager.h"
#import "NLSong+WCDB.h"

// 定义下载歌曲的专属表名
static NSString * const kDownloadedSongsTableName = @"DownloadedSongsTable";
static NSString * const kHistoryTableName = @"PlaybackHistoryTable";
static NSString * const kLikedSongsTableName = @"LikedSongsTable";

@implementation NLSongRepository

+ (WCTDatabase *)safeDatabase {
    WCTDatabase *db = [NLDataBaseManager sharedManager].database;
    [db createTable:kDownloadedSongsTableName withClass:NLSong.class];
    [db createTable:kHistoryTableName withClass:NLSong.class];
    [db createTable:kLikedSongsTableName withClass:NLSong.class];
    return db;
}

/// 添加 / 更新下载歌曲
+ (BOOL)addDownloadedSong:(NLSong *)song {
    if (!song || !song.songId) return NO;

    BOOL result = [[self safeDatabase] insertOrReplaceObject:song intoTable:kDownloadedSongsTableName];
    if (!result) NSLog(@"保存下载歌曲失败");
    return result;
}

/// 删除下载歌曲
+ (BOOL)removeDownloadedSong:(NSString *)songId {
    if (songId.length == 0) return NO;

    // ✨ v2 API: deleteObjectsFromTable:where:
    BOOL result = [[self safeDatabase] deleteFromTable:kDownloadedSongsTableName
                                                        where:NLSong.songId == songId];
    if (!result) NSLog(@"删除下载歌曲失败");
    return result;
}

/// 判断歌曲是否已经下载
+ (BOOL)isSongDownloaded:(NSString *)songId {
    if (songId.length == 0) return NO;

    // ✨ v2 API: getObjectOfClass:fromTable:where: (注意：去掉了 One)
    NLSong *existSong = [[self safeDatabase] getObjectOfClass:NLSong.class
                                                    fromTable:kDownloadedSongsTableName
                                                        where:NLSong.songId == songId];
    return existSong != nil;
}

/// 查询全部下载歌曲
+ (NSArray<NLSong *> *)allDownloadedSongs {
    NSArray<NLSong *> *songs = [[self safeDatabase] getObjectsOfClass:NLSong.class
                                                               fromTable:kDownloadedSongsTableName];
    return songs ?: @[];
}

/// 添加到播放历史
+ (BOOL)addPlayHistory:(NLSong *)song {
    if (!song || !song.songId) return NO;
    // ✨ 魔法：直接塞进历史表里，因为是 replace，所以同一首歌反复播放只会更新，不会重复！
    return [[self safeDatabase] insertOrReplaceObject:song intoTable:kHistoryTableName];
}

/// 从播放历史中移除一条
+ (BOOL)removePlayHistoryWithSongId:(NSString *)songId {
    if (songId.length == 0) return NO;
    return [[self safeDatabase] deleteFromTable:kHistoryTableName where:NLSong.songId == songId];
}

/// 获取播放历史
+ (NSArray<NLSong *> *)allPlayHistory {
    return [[self safeDatabase] getObjectsOfClass:NLSong.class fromTable:kHistoryTableName];
}

#pragma mark - 收藏单曲业务

/// 获取全部「喜欢的单曲」
+ (NSArray<NLSong *> *)allLikedSongs {
    NSArray<NLSong *> *songs = [[self safeDatabase] getObjectsOfClass:NLSong.class
                                                             fromTable:kLikedSongsTableName];
    return songs ?: @[];
}

/// 收藏/取消收藏单曲
+ (BOOL)likeSong:(NLSong *)song isLike:(BOOL)isLike {
    if (!song || !song.songId) return NO;
    if (isLike) {
        // 收藏：存入喜欢表
        return [[self safeDatabase] insertOrReplaceObject:song intoTable:kLikedSongsTableName];
    } else {
        // 取消收藏：从喜欢表中删除
        return [[self safeDatabase] deleteFromTable:kLikedSongsTableName where:NLSong.songId == song.songId];
    }
}

/// 判断单曲是否已收藏
+ (BOOL)isSongLiked:(NSString *)songId {
    if (songId.length == 0) return NO;
    NLSong *existSong = [[self safeDatabase] getObjectOfClass:NLSong.class
                                                    fromTable:kLikedSongsTableName
                                                        where:NLSong.songId == songId];
    return existSong != nil;
}
@end
