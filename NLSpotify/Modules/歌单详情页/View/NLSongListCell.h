//
//  NLSongCell.h
//  NLSpotify
//
//  Created by 吴桐 on 2026/1/8.
//

#import <UIKit/UIKit.h>

@class NLListCellModel, NLSong, NLPlayList, NLAlbum, NLDownloadItem;

NS_ASSUME_NONNULL_BEGIN

@interface NLSongListCell : UITableViewCell

- (void)configWithSong:(NLListCellModel *)song;
/// 直接用 NLSong 展示（用于最近播放、喜欢等本地列表）
- (void)configWithNLSong:(NLSong *)song;
/// 用同一套 UI 展示歌单（封面 + 标题 + 副标题，与歌曲行统一）
- (void)configWithPlayList:(NLPlayList *)playList;
/// 用同一套 UI 展示专辑（封面 + 标题 + 艺人名）
- (void)configWithAlbum:(NLAlbum *)album;
/// 下载项：progress 0~1 为下载中并显示进度条，<0 或 >=1 不显示进度条
- (void)configWithDownloadItem:(NLDownloadItem *)item downloadProgress:(float)progress;

@end

NS_ASSUME_NONNULL_END
