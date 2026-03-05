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
- (void)configWithNLSong:(NLSong *)song;
- (void)configWithPlayList:(NLPlayList *)playList;
- (void)configWithAlbum:(NLAlbum *)album;
- (void)configWithDownloadItem:(NLDownloadItem *)item downloadProgress:(float)progress;

@end

NS_ASSUME_NONNULL_END
