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
/// 清空已下载歌曲表（用于一键清空）
+ (void)clearAllDownloadedSongs;
+ (BOOL)addPlayHistory:(NLSong *)song;
+ (BOOL)removePlayHistoryWithSongId:(NSString *)songId;
+ (NSArray<NLSong *> *)allPlayHistory;

+ (NSArray<NLSong *> *)allLikedSongs;
+ (BOOL)likeSong:(NLSong *)song isLike:(BOOL)isLike;
+ (BOOL)isSongLiked:(NSString *)songId;

@end

NS_ASSUME_NONNULL_END
