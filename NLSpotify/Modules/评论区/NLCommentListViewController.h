//
//  NLCommentListViewController.h
//  NLSpotify
//
//  评论区页：单曲/歌单/专辑通用，展示评论列表
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, NLCommentListResourceType) {
    NLCommentListResourceTypeSong = 0,
    NLCommentListResourceTypePlaylist = 2,
    NLCommentListResourceTypeAlbum = 3,
};

@interface NLCommentListViewController : UIViewController

- (instancetype)initWithResourceId:(NSInteger)resourceId
                     resourceType:(NLCommentListResourceType)type
                            title:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
