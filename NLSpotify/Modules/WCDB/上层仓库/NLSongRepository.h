//
//  NLSongRepository.h
//  NLSpotify
//
//  Created by 吴桐 on 2026/2/23.
//

#import <Foundation/Foundation.h>

@class NLSong;

NS_ASSUME_NONNULL_BEGIN

@interface NLSongRepository : NSObject

+ (BOOL)addDownloadedSong:(NLSong *)song;
+ (BOOL)removeDownloadedSong:(NSString *)songId;
+ (BOOL)isSongDownloaded:(NSString *)songId;
+ (NSArray<NLSong *> *)allDownloadedSongs;
+ (BOOL)addPlayHistory:(NLSong *)song;
+ (BOOL)removePlayHistoryWithSongId:(NSString *)songId;
+ (NSArray<NLSong *> *)allPlayHistory;
/// 获取全部「喜欢的单曲」
+ (NSArray<NLSong *> *)allLikedSongs;
+ (BOOL)likeSong:(NLSong *)song isLike:(BOOL)isLike;
/// 判断某首歌是否已被收藏
+ (BOOL)isSongLiked:(NSString *)songId;

@end

NS_ASSUME_NONNULL_END
