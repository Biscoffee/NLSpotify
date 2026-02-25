//
//  NLPlayList.m
//  NLSpotify
//
//  Created by 吴桐 on 2026/2/23.
//

#import "NLPlayList.h"
#import "NLPlayList+WCDB.h"

@implementation NLPlayList

WCDB_IMPLEMENTATION(NLPlayList)
WCDB_SYNTHESIZE(playlistId)
WCDB_SYNTHESIZE(name)
WCDB_SYNTHESIZE(coverURL)
WCDB_SYNTHESIZE(isUserCreated)
WCDB_SYNTHESIZE(createTime)

WCDB_PRIMARY(playlistId) // 歌单 ID 作为绝对主键

- (instancetype)initWithId:(NSString *)playlistId name:(NSString *)name isUserCreated:(BOOL)isUserCreated {
    if (self = [super init]) {
        _playlistId = playlistId;
        _name = name;
        _isUserCreated = isUserCreated;
        _createTime = [[NSDate date] timeIntervalSince1970];
    }
    return self;
}
@end
