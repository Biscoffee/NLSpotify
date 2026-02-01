//
//  NLPlayListSmallCell.h
//  NLSpotify
//
//  Created by 吴桐 on 2025/12/13.
//
//适用于最近播放、热门歌单等
#import "NLHomeSectionCell.h"
#import "NLRecommendAlbumListModel.h"

NS_ASSUME_NONNULL_BEGIN

@class NLRecommendAlbumListModel;

@interface NLPlayListSmallCell : NLHomeSectionCell

@property (nonatomic, copy) void(^didSelectPlayList)(NLRecommendAlbumListModel *model);

@end

@interface PlayListSmallCollectionCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *coverImgView;
@property (nonatomic, strong) UILabel *nameLabel;
- (void)configWithModel:(NLRecommendAlbumListModel *)model;
@end


NS_ASSUME_NONNULL_END
