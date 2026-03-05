//
//  NLMusicLibraryListViewController.h
//  NLSpotify
//
//  音乐库子项统一列表页：播放历史、收藏的歌单、创建的歌单、歌曲 共用此 VC，仅数据源与右上角加号不同，全部支持左滑删除。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, NLMusicLibraryListMode) {
    NLMusicLibraryListModeRecentPlay,       // 播放历史（歌曲列表）
    NLMusicLibraryListModeLikedPlaylists,   // 收藏的歌单
    NLMusicLibraryListModeMyPlaylists,      // 创建的歌单（右上角有加号）
    NLMusicLibraryListModeCachedSongs,      // 缓存（已完全缓存并转为 mp3 的歌曲）
    NLMusicLibraryListModeDownloadedSongs,  // 我下载的音乐（含下载中进度）
    NLMusicLibraryListModeLikedAlbums,      // 我收藏的专辑
    NLMusicLibraryListModeLikedSongs        // 歌曲（我喜欢的歌曲）
};

@interface NLMusicLibraryListViewController : UIViewController

- (instancetype)initWithMode:(NLMusicLibraryListMode)mode;

@end

NS_ASSUME_NONNULL_END
