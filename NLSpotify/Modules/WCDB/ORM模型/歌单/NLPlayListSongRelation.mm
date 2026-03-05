//
//  NLPlayListSongRelation.m
//  NLSpotify
//
//  Created by 吴桐 on 2026/2/23.
//

#import "NLPlayListSongRelation.h"
#import "NLPlayListSongRelation+WCDB.h"

@implementation NLPlayListSongRelation

WCDB_IMPLEMENTATION(NLPlayListSongRelation)
WCDB_SYNTHESIZE(playlistId)
WCDB_SYNTHESIZE(songId)
WCDB_SYNTHESIZE(addTime)

// 这里为了防止引发 WCDB 多主键的 C++ 编译报错我们不设主键去重的逻辑，我们直接交给Repository

- (instancetype)initWithPlaylistId:(NSString *)playlistId songId:(NSString *)songId {
    if (self = [super init]) {
        _playlistId = playlistId;
        _songId = songId;
        _addTime = [[NSDate date] timeIntervalSince1970];
    }
    return self;
}
@end
