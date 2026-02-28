//
//  NLDownloadManager.h
//  NLSpotify
//
//  后台下载到本地缓存，完成后写入 DownloadedSongsTable
//

#import <Foundation/Foundation.h>

@class NLSong;

NS_ASSUME_NONNULL_BEGIN

extern NSNotificationName const NLDownloadManagerDidUpdateNotification;

@interface NLDownloadManager : NSObject

+ (instancetype)sharedManager;

/// 加入下载队列并开始下载（若已有 playURL 则直接下，否则先拉取 playURL）
- (void)addDownloadForSong:(NLSong *)song;

/// 是否正在下载该 songId
- (BOOL)isDownloadingSongId:(NSString *)songId;

/// 取消所有进行中的下载任务（用于一键清空前）
- (void)cancelAllDownloads;

@end

NS_ASSUME_NONNULL_END
