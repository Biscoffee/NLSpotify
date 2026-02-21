//
//  NLPlaylistCell.h
//  NLSpotify
//
//  歌单小卡片（封面+标题），用于「为你推荐」等
//

#import "NLHomeSectionCell.h"
#import "NLRecommendAlbumListModel.h"

NS_ASSUME_NONNULL_BEGIN

@class NLRecommendAlbumListModel;

@interface NLPlaylistCell : NLHomeSectionCell
@property (nonatomic, copy) void(^didSelectPlaylist)(NLRecommendAlbumListModel *model);
@end

@interface PlaylistCollectionCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *coverImgView;
@property (nonatomic, strong) UILabel *nameLabel;
- (void)configWithModel:(NLRecommendAlbumListModel *)model;
@end

NS_ASSUME_NONNULL_END
