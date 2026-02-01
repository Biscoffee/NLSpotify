//
//  NLSongListViewController.h
//  NLSpotify
//
//  Created by 吴桐 on 2026/1/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, NLSongListType) {
    NLSongListTypePlaylist,
    NLSongListTypeAlbum
};

@interface NLSongListViewController : UIViewController
- (instancetype)initWithId:(NSInteger)listId
                      type:(NLSongListType)type
                      name:(NSString *)name;
@end

NS_ASSUME_NONNULL_END
