//
//  NLPlayListBigCell.h
//  NLSpotify
//
//  Created by 吴桐 on 2025/12/13.
//

//适用于某位歌手的推荐歌单

#import "NLHomeSectionCell.h"
#import "NLSingerAlbumListModel.h"

@class NLSingerAlbumListModel;

NS_ASSUME_NONNULL_BEGIN

@interface NLPlayListBigCell : NLHomeSectionCell

@end

@interface PlayListBigCollectionCell : UICollectionViewCell

- (void)configWithModel:(NLSingerAlbumListModel *)model;
@end

NS_ASSUME_NONNULL_END
