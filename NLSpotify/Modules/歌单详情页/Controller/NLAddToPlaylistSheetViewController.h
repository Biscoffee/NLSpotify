//
//  NLAddToPlaylistSheetViewController.h
//  NLSpotify
//
//  播放器「加号」弹出的「收藏到歌单」半屏弹窗：顶部为新建歌单，下方为现有歌单列表；新建后自动将当前歌曲加入该歌单。
//

#import <UIKit/UIKit.h>

@class NLSong;

NS_ASSUME_NONNULL_BEGIN

@interface NLAddToPlaylistSheetViewController : UIViewController

/// 要加入歌单的当前歌曲，由调用方设置
@property (nonatomic, strong) NLSong *currentSong;

@end

NS_ASSUME_NONNULL_END
