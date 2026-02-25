//
//  NLAlbum.mm
//  NLSpotify
//

#import "NLAlbum.h"
#import "NLAlbum+WCDB.h"

@implementation NLAlbum

WCDB_IMPLEMENTATION(NLAlbum)
WCDB_SYNTHESIZE(albumId)
WCDB_SYNTHESIZE(name)
WCDB_SYNTHESIZE(coverURL)
WCDB_SYNTHESIZE(artistName)
WCDB_SYNTHESIZE(createTime)

WCDB_PRIMARY(albumId)

- (instancetype)initWithAlbumId:(NSString *)albumId name:(NSString *)name coverURL:(NSString *)coverURL artistName:(NSString *)artistName {
    if (self = [super init]) {
        _albumId = albumId ?: @"";
        _name = name ?: @"";
        _coverURL = coverURL ?: @"";
        _artistName = artistName ?: @"";
        _createTime = [[NSDate date] timeIntervalSince1970];
    }
    return self;
}

@end
