//
//  NLAlbumRepository.mm
//  NLSpotify
//
//  Created by 吴桐 on 2026/2/23.
//


#import "NLAlbumRepository.h"
#import "NLDataBaseManager.h"
#import "NLAlbum.h"
#import "NLAlbum+WCDB.h"

static NSString * const kLikedAlbumsTableName = @"LikedAlbumsTable";

@implementation NLAlbumRepository

+ (WCTDatabase *)safeDatabase {
    WCTDatabase *db = [NLDataBaseManager sharedManager].database;
    [db createTable:kLikedAlbumsTableName withClass:NLAlbum.class];
    return db;
}

+ (NSArray<NLAlbum *> *)allLikedAlbums {
    NSArray<NLAlbum *> *list = [[self safeDatabase] getObjectsOfClass:NLAlbum.class
                                                             fromTable:kLikedAlbumsTableName];
    if (!list) return @[];
    return [list sortedArrayUsingComparator:^NSComparisonResult(NLAlbum *a, NLAlbum *b) {
        if (a.createTime > b.createTime) return NSOrderedAscending;
        if (a.createTime < b.createTime) return NSOrderedDescending;
        return NSOrderedSame;
    }];
}

+ (BOOL)setAlbum:(NLAlbum *)album liked:(BOOL)liked {
    if (!album || !album.albumId.length) return NO;
    if (liked) {
        if (album.createTime <= 0) {
            album.createTime = [[NSDate date] timeIntervalSince1970];
        }
        return [[self safeDatabase] insertOrReplaceObject:album intoTable:kLikedAlbumsTableName];
    } else {
        return [[self safeDatabase] deleteFromTable:kLikedAlbumsTableName where:NLAlbum.albumId == album.albumId];
    }
}

+ (BOOL)isAlbumLiked:(NSString *)albumId {
    if (albumId.length == 0) return NO;
    NLAlbum *exist = [[self safeDatabase] getObjectOfClass:NLAlbum.class
                                                 fromTable:kLikedAlbumsTableName
                                                     where:NLAlbum.albumId == albumId];
    return exist != nil;
}

@end
