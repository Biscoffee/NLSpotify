//
//  NLLikedSongsPickerViewController.h
//  NLSpotify
//
//  从「我喜欢的歌曲」中选择要添加到某个自建歌单
//

#import <UIKit/UIKit.h>

@class NLPlayList;

NS_ASSUME_NONNULL_BEGIN

@interface NLLikedSongsPickerViewController : UIViewController

- (instancetype)initWithPlayList:(NLPlayList *)playlist;

@end

NS_ASSUME_NONNULL_END

