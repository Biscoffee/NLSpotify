//
//  NLSongService.h
//  NLSpotify
//
//  Created by 吴桐 on 2026/1/19.
//

#import <Foundation/Foundation.h>
#import "NLSong.h"
#import "NetWorkManager.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^SongURLFetchSuccess)(NSURL *playURL);
typedef void(^SongFetchFailure)(NSError *error);
typedef void(^SongLyricFetchSuccess)(NSString *lyric);

@interface NLSongService : NSObject

+ (instancetype)sharedService;

- (void)fetchPlayableURLWithSongId:(NSString *)songId
                           success:(SongURLFetchSuccess)success
                           failure:(SongFetchFailure)failure;

// 获取歌词原始 LRC 文本
- (void)fetchLyricWithSongId:(NSString *)songId
                     success:(SongLyricFetchSuccess)success
                     failure:(SongFetchFailure)failure;

@end

NS_ASSUME_NONNULL_END
