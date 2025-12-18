//
//  NLSingerCell.h
//  NLSpotify
//
//  Created by 吴桐 on 2025/12/13.
//
//用于：你最爱的艺人

#import "NLHomeSectionCell.h"
#import "NLRecommendAlbumListModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NLSingerCell : NLHomeSectionCell

@end

@interface PlayListSingerCollectionCell : UICollectionView
@property (nonatomic, strong) UIImageView *coverImgView;
@property (nonatomic, strong) UILabel *nameLabel;
-(void)configWithModel:(NLRecommendAlbumListModel *)model;

@end

NS_ASSUME_NONNULL_END
