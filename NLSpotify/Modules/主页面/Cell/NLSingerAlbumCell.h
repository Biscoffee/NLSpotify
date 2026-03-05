//
//  NLSingerAlbumCell.h
//  NLSpotify
//
//  歌手专辑大卡片（头像+用户名+封面列表）
//

#import "NLHomeSectionCell.h"
#import "NLSingerAlbumListModel.h"

@class NLSingerAlbumListModel;

NS_ASSUME_NONNULL_BEGIN

@interface NLSingerAlbumCell : NLHomeSectionCell

@property (nonatomic, copy) void(^didSelectSingerAlbum)(NLSingerAlbumListModel *model);

@end

@interface SingerAlbumCollectionCell : UICollectionViewCell

- (void)configWithModel:(NLSingerAlbumListModel *)model;
@end

NS_ASSUME_NONNULL_END
