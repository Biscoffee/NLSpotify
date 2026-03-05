//
//  NLPlayListRepository.mm
//  NLSpotify
//
//  Created by 吴桐 on 2026/2/24.
//

#import "NLPlayListRepository.h"
#import "NLDataBaseManager.h"
#import "NLPlayList.h"
#import "NLPlayListSongRelation.h"
#import "NLSong.h"
#import "NLPlayList+WCDB.h"
#import "NLPlayListSongRelation+WCDB.h"
#import "NLSong+WCDB.h"

static NSString * const kPlayListTableName = @"PlayListTable";              // 歌单表
static NSString * const kRelationTableName = @"PlayListSongRelationTable";  // 关系映射表
static NSString * const kLocalSongsTableName = @"LocalSongsCacheTable";   // 歌曲全量缓存表 (防止歌单里只有 ID 找不到真实歌曲)

@implementation NLPlayListRepository

+ (WCTDatabase *)safeDatabase {
    WCTDatabase *db = [NLDataBaseManager sharedManager].database;
    // 一次性确保三张表都存在
    [db createTable:kPlayListTableName withClass:NLPlayList.class];
    [db createTable:kRelationTableName withClass:NLPlayListSongRelation.class];
    [db createTable:kLocalSongsTableName withClass:NLSong.class];
    return db;
}

+ (BOOL)savePlayList:(NLPlayList *)playList {
    if (!playList || !playList.playlistId) return NO;
    return [[self safeDatabase] insertOrReplaceObject:playList intoTable:kPlayListTableName];
}

+ (BOOL)deletePlayList:(NSString *)playListId {
    if (playListId.length == 0) return NO;
    WCTDatabase *db = [self safeDatabase];

    //删除歌单本体
    BOOL r1 = [db deleteFromTable:kPlayListTableName where:NLPlayList.playlistId == playListId];
    //把关系表里属于这个歌单的关联记录也全部删光
    BOOL r2 = [db deleteFromTable:kRelationTableName where:NLPlayListSongRelation.playlistId == playListId];
    return r1 && r2;
}

//根据类型查歌单并排序
+ (NSArray<NLPlayList *> *)getPlayListsByUserCreated:(BOOL)isUserCreated {
    NSArray<NLPlayList *> *lists = [[self safeDatabase] getObjectsOfClass:NLPlayList.class
                                                                fromTable:kPlayListTableName
                                                                    where:NLPlayList.isUserCreated == isUserCreated];
    if (!lists) return @[];
    return [lists sortedArrayUsingComparator:^NSComparisonResult(NLPlayList *obj1, NLPlayList *obj2) {
        if (obj1.createTime > obj2.createTime) return NSOrderedAscending;
        if (obj1.createTime < obj2.createTime) return NSOrderedDescending;
        return NSOrderedSame;
    }];
}

+ (NSArray<NLPlayList *> *)allUserCreatedPlayLists {
    return [self getPlayListsByUserCreated:YES];
}

+ (NSArray<NLPlayList *> *)allLikedPlayLists {
    return [self getPlayListsByUserCreated:NO];
}

+ (BOOL)markPlayList:(NLPlayList *)playList userCreated:(BOOL)isUserCreated {
    if (!playList || !playList.playlistId) return NO;
    playList.isUserCreated = isUserCreated;
    return [self savePlayList:playList];
}

+ (BOOL)setPlayList:(NLPlayList *)playList liked:(BOOL)liked {
    if (!playList || !playList.playlistId) return NO;
    if (liked) {
        playList.isUserCreated = NO;
        if (playList.createTime <= 0) {
            playList.createTime = [[NSDate date] timeIntervalSince1970];
        }
        return [self savePlayList:playList];
    } else {
        return [self deletePlayList:playList.playlistId];
    }
}

+ (BOOL)isPlayListLiked:(NSString *)playListId {
    if (playListId.length == 0) return NO;
    NLPlayList *exist = [[self safeDatabase] getObjectOfClass:NLPlayList.class
                                                    fromTable:kPlayListTableName
                                                        where:NLPlayList.playlistId == playListId && NLPlayList.isUserCreated == NO];
    return exist != nil;
}

#pragma mark - 歌单内部歌曲管理

+ (BOOL)addSong:(NLSong *)song toPlayList:(NSString *)playListId {
    if (!song || !song.songId || playListId.length == 0) return NO;
    WCTDatabase *db = [self safeDatabase];
    [db insertOrReplaceObject:song intoTable:kLocalSongsTableName];
    NLPlayListSongRelation *existRel = [db getObjectOfClass:NLPlayListSongRelation.class
                                                  fromTable:kRelationTableName
                                                      where:NLPlayListSongRelation.playlistId == playListId && NLPlayListSongRelation.songId == song.songId];
    if (existRel) return YES;
    NLPlayListSongRelation *relation = [[NLPlayListSongRelation alloc] initWithPlaylistId:playListId songId:song.songId];
    BOOL ok = [db insertObject:relation intoTable:kRelationTableName];

    // 更新歌单封面为最新添加歌曲的封面
    if (ok && song.coverURL.absoluteString.length > 0) {
        NLPlayList *playlist = [db getObjectOfClass:NLPlayList.class
                                          fromTable:kPlayListTableName
                                              where:NLPlayList.playlistId == playListId];
        if (playlist) {
            playlist.coverURL = song.coverURL.absoluteString;
            [db insertOrReplaceObject:playlist intoTable:kPlayListTableName];
        }
    }
    return ok;
}

+ (BOOL)removeSong:(NSString *)songId fromPlayList:(NSString *)playListId {
    if (songId.length == 0 || playListId.length == 0) return NO;
    return [[self safeDatabase] deleteFromTable:kRelationTableName
                                          where:NLPlayListSongRelation.playlistId == playListId && NLPlayListSongRelation.songId == songId];
}

+ (NSArray<NLSong *> *)songsInPlayList:(NSString *)playListId {
    if (playListId.length == 0) return @[];
    WCTDatabase *db = [self safeDatabase];
    NSArray<NLPlayListSongRelation *> *relations = [db getObjectsOfClass:NLPlayListSongRelation.class
                                                               fromTable:kRelationTableName
                                                                   where:NLPlayListSongRelation.playlistId == playListId];
    if (!relations || relations.count == 0) return @[];
    NSArray *sortedRels = [relations sortedArrayUsingComparator:^NSComparisonResult(NLPlayListSongRelation *obj1, NLPlayListSongRelation *obj2) {
        if (obj1.addTime > obj2.addTime) return NSOrderedAscending;
        if (obj1.addTime < obj2.addTime) return NSOrderedDescending;
        return NSOrderedSame;
    }];
    NSMutableArray<NLSong *> *resultSongs = [NSMutableArray array];
    for (NLPlayListSongRelation *rel in sortedRels) {
        NLSong *song = [db getObjectOfClass:NLSong.class
                                  fromTable:kLocalSongsTableName
                                      where:NLSong.songId == rel.songId];
        if (song) {
            [resultSongs addObject:song];
        }
    }

    return resultSongs;
}

+ (nullable NLPlayList *)createUserPlayListWithName:(NSString *)name {
    NSString *trimmed = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmed.length == 0) return nil;
    // 使用时间戳生成本地唯一 ID
    long long ts = (long long)([[NSDate date] timeIntervalSince1970] * 1000);
    NSString *pid = [NSString stringWithFormat:@"local_%lld", ts];
    NLPlayList *playList = [[NLPlayList alloc] initWithId:pid name:trimmed isUserCreated:YES];
    playList.createTime = [[NSDate date] timeIntervalSince1970];
    BOOL ok = [self savePlayList:playList];
    return ok ? playList : nil;
}

@end
