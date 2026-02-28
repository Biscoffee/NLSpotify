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

+ (BOOL)addDownloadedSong:(NLSong *)song {
    if (!song || !song.songId) return NO;
    BOOL result = [[self safeDatabase] insertOrReplaceObject:song intoTable:kDownloadedSongsTableName];
    if (!result) NSLog(@"保存下载歌曲失败");
    return result;
}

+ (BOOL)removeDownloadedSong:(NSString *)songId {
    if (songId.length == 0) return NO;
    BOOL result = [[self safeDatabase] deleteFromTable:kDownloadedSongsTableName
                                                        where:NLSong.songId == songId];
    if (!result) NSLog(@"删除下载歌曲失败");
    return result;
}
+ (BOOL)isSongDownloaded:(NSString *)songId {
    if (songId.length == 0) return NO;
    NLSong *existSong = [[self safeDatabase] getObjectOfClass:NLSong.class
                                                    fromTable:kDownloadedSongsTableName
                                                        where:NLSong.songId == songId];
    return existSong != nil;
}

+ (NSArray<NLSong *> *)allDownloadedSongs {
    NSArray<NLSong *> *songs = [[self safeDatabase] getObjectsOfClass:NLSong.class
                                                               fromTable:kDownloadedSongsTableName];
    return songs ?: @[];
}

+ (void)clearAllDownloadedSongs {
    [self safeDatabase];
    [[self safeDatabase] deleteFromTable:kDownloadedSongsTableName];
}

+ (BOOL)addPlayHistory:(NLSong *)song {
    if (!song || !song.songId) return NO;
    return [[self safeDatabase] insertOrReplaceObject:song intoTable:kHistoryTableName];
}
+ (BOOL)removePlayHistoryWithSongId:(NSString *)songId {
    if (songId.length == 0) return NO;
    return [[self safeDatabase] deleteFromTable:kHistoryTableName where:NLSong.songId == songId];
}

+ (NSArray<NLSong *> *)allPlayHistory {
    return [[self safeDatabase] getObjectsOfClass:NLSong.class fromTable:kHistoryTableName];
}

#pragma mark - 收藏单曲业务

+ (NSArray<NLSong *> *)allLikedSongs {
    NSArray<NLSong *> *songs = [[self safeDatabase] getObjectsOfClass:NLSong.class
                                                             fromTable:kLikedSongsTableName];
    return songs ?: @[];
}

+ (BOOL)likeSong:(NLSong *)song isLike:(BOOL)isLike {
    if (!song || !song.songId) return NO;
    if (isLike) {
        return [[self safeDatabase] insertOrReplaceObject:song intoTable:kLikedSongsTableName];
    } else {
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
