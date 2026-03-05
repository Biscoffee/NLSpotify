//
//  NLDownloadManager.h
//  NLSpotify
//
//  后台下载到本地缓存，完成后写入 DownloadedSongsTable
//

#import <Foundation/Foundation.h>

@class NLSong;

NS_ASSUME_NONNULL_BEGIN

/// 下载任务进度或状态变更时发送的通知。
/// - Discussion: `userInfo` 中通常会包含下载队列与进度信息，供 UI 刷新使用。
extern NSNotificationName const NLDownloadManagerDidUpdateNotification;

@interface NLDownloadManager : NSObject

/// 全局下载管理单例。
/// - Returns: 全局共享的 `NLDownloadManager` 实例。
+ (instancetype)sharedManager;
/// 为指定歌曲添加一个下载任务。
/// - Parameter song: 需要下载到本地缓存的歌曲。
- (void)addDownloadForSong:(NLSong *)song;
/// 是否正在下载指定歌曲。
/// - Parameter songId: 歌曲的唯一标识。
/// - Returns: 若该歌曲存在进行中的下载任务则为 YES。
- (BOOL)isDownloadingSongId:(NSString *)songId;
/// 取消所有进行中的下载任务。
- (void)cancelAllDownloads;

@end

NS_ASSUME_NONNULL_END
