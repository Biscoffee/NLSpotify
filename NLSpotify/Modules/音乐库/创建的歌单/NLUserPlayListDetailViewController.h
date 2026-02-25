//
//  NLUserPlayListDetailViewController.h
//  NLSpotify
//

#import <UIKit/UIKit.h>

@class NLPlayList;

NS_ASSUME_NONNULL_BEGIN

@interface NLUserPlayListDetailViewController : UIViewController

- (instancetype)initWithPlayList:(NLPlayList *)playlist;

@end

NS_ASSUME_NONNULL_END

