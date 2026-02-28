//
//  NLDownloadRepository.h
//  NLSpotify
//

#import <Foundation/Foundation.h>

@class NLDownloadItem, NLSong;

NS_ASSUME_NONNULL_BEGIN

@interface NLDownloadRepository : NSObject

+ (void)safeCreateTable;

/// 按 addedTime 从新到旧
+ (NSArray<NLDownloadItem *> *)allDownloadItems;

+ (nullable NLDownloadItem *)downloadItemForSongId:(NSString *)songId;

+ (BOOL)addDownloadItemWithSong:(NLSong *)song status:(NSString *)status;

+ (BOOL)updateStatus:(NSString *)status forSongId:(NSString *)songId;

+ (BOOL)removeDownloadItemWithSongId:(NSString *)songId;

/// 清空下载队列表（用于一键清空，需配合 NLDownloadManager cancelAllDownloads）
+ (void)clearAllDownloadItems;

@end

NS_ASSUME_NONNULL_END
