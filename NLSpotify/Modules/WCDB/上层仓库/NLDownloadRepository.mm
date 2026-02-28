//
//  NLDownloadRepository.mm
//  NLSpotify
//

#import "NLDownloadRepository.h"
#import "NLDownloadItem.h"
#import "NLDownloadItem+WCDB.h"
#import "NLDataBaseManager.h"
#import "NLSong.h"

static NSString * const kDownloadQueueTableName = @"DownloadQueueTable";

@implementation NLDownloadRepository

+ (void)safeCreateTable {
    WCTDatabase *db = [NLDataBaseManager sharedManager].database;
    [db createTable:kDownloadQueueTableName withClass:NLDownloadItem.class];
}

+ (NSArray<NLDownloadItem *> *)allDownloadItems {
    [self safeCreateTable];
    NSArray<NLDownloadItem *> *list = [[NLDataBaseManager sharedManager].database getObjectsOfClass:NLDownloadItem.class fromTable:kDownloadQueueTableName];
    if (!list) return @[];
    return [list sortedArrayUsingComparator:^NSComparisonResult(NLDownloadItem *a, NLDownloadItem *b) {
        if (a.addedTime > b.addedTime) return NSOrderedAscending;
        if (a.addedTime < b.addedTime) return NSOrderedDescending;
        return NSOrderedSame;
    }];
}

+ (NLDownloadItem *)downloadItemForSongId:(NSString *)songId {
    if (songId.length == 0) return nil;
    [self safeCreateTable];
    return [[NLDataBaseManager sharedManager].database getObjectOfClass:NLDownloadItem.class fromTable:kDownloadQueueTableName where:NLDownloadItem.songId == songId];
}

+ (BOOL)addDownloadItemWithSong:(NLSong *)song status:(NSString *)status {
    if (!song || !song.songId.length) return NO;
    [self safeCreateTable];
    NLDownloadItem *item = [[NLDownloadItem alloc] init];
    item.songId = song.songId;
    item.playURLString = song.playURL.absoluteString ?: @"";
    item.title = song.title ?: @"";
    item.artist = song.artist ?: @"";
    item.coverURLString = song.coverURL.absoluteString ?: @"";
    item.addedTime = [[NSDate date] timeIntervalSince1970];
    item.status = status ?: @"downloading";
    return [[NLDataBaseManager sharedManager].database insertOrReplaceObject:item intoTable:kDownloadQueueTableName];
}

+ (BOOL)updateStatus:(NSString *)status forSongId:(NSString *)songId {
    if (songId.length == 0 || !status.length) return NO;
    NLDownloadItem *item = [self downloadItemForSongId:songId];
    if (!item) return NO;
    item.status = status;
    return [[NLDataBaseManager sharedManager].database insertOrReplaceObject:item intoTable:kDownloadQueueTableName];
}

+ (BOOL)removeDownloadItemWithSongId:(NSString *)songId {
    if (songId.length == 0) return NO;
    return [[NLDataBaseManager sharedManager].database deleteFromTable:kDownloadQueueTableName where:NLDownloadItem.songId == songId];
}

+ (void)clearAllDownloadItems {
    [NLDownloadRepository safeCreateTable];
    [[NLDataBaseManager sharedManager].database deleteFromTable:kDownloadQueueTableName];
}

@end
