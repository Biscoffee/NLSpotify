//
//  NLMusicPlayerAccessoryViewController.h
//  NLSpotify
//
//  Created by 吴桐 on 2026/1/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NLMusicPlayerAccessoryViewController : UIViewController

- (void)playSongWithId:(NSString *)songId
                 title:(NSString *)title
                artist:(NSString *)artist
              coverURL:(NSURL * _Nullable)coverURL;

@end

NS_ASSUME_NONNULL_END
