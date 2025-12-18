//
//  NLPlayListBigCell.m
//  NLSpotify
//
//  Created by 吴桐 on 2025/12/13.
//

#import "NLPlayListBigCell.h"
#import "Masonry/Masonry.h"
#import "NLSingerAlbumListModel.h"
#import "SDWebImage/SDWebImage.h"

@implementation PlayListBigCollectionCell
{

  UIImageView *_coverImageView;//歌单封面
  UIImageView *_spotifyIconView;//spotify logo
  UILabel *_titleLabel;//歌单标题
  UILabel *_subtitleLabel;//歌单描述
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = UIColor.blackColor;

        // 歌单封面
        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.layer.cornerRadius = 14;
        _coverImageView.clipsToBounds = YES;
        [self.contentView addSubview:_coverImageView];

        // Spotify 图标
        _spotifyIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"spotify.png"]];
        [_coverImageView addSubview:_spotifyIconView];

        // 歌单标题
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:15];
        _titleLabel.textColor = UIColor.whiteColor;
        [self.contentView addSubview:_titleLabel];

        // 歌单描述
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.font = [UIFont systemFontOfSize:13];
        _subtitleLabel.textColor = [UIColor colorWithWhite:1 alpha:0.6];
        _subtitleLabel.numberOfLines = 2;
        [self.contentView addSubview:_subtitleLabel];

        [_coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top).offset(12);
            make.left.right.equalTo(self.contentView);
            make.height.mas_equalTo(200);
        }];

        [_spotifyIconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(_coverImageView).offset(10);
            make.width.height.mas_equalTo(22);
        }];

        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_coverImageView.mas_bottom).offset(8);
            make.left.right.equalTo(self.contentView).inset(0);
        }];

        [_subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_titleLabel.mas_bottom).offset(4);
            make.left.right.equalTo(self.contentView);
            make.bottom.lessThanOrEqualTo(self.contentView);
        }];
    }
    return self;
}

- (void)configWithModel:(NLSingerAlbumListModel *)model {
    if (!model) return;
  [_coverImageView sd_setImageWithURL:[NSURL URLWithString:model.coverUrl] placeholderImage:nil];
    // 歌单标题和描述
    _titleLabel.text = model.title;
    _subtitleLabel.text = model.subtitle;
}

@end



@implementation NLPlayListBigCell

- (void)registerCollectionCells {
  [self.collectionView registerClass:PlayListBigCollectionCell.class forCellWithReuseIdentifier:@"PlayListBigCollectionCell"];
  self.collectionView.backgroundColor = UIColor.blackColor;
  self.contentView.backgroundColor = UIColor.blackColor;
  self.backgroundColor = UIColor.blackColor;

  self.titleLabel.textColor = [UIColor whiteColor];
}

- (CGSize)sizeForCollectionCell {
  return CGSizeMake(200, 280);
}

- (UICollectionViewCell *)configureCollectionCell:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath item:(id)item {
  PlayListBigCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PlayListBigCollectionCell" forIndexPath:indexPath];
  [cell configWithModel:(NLSingerAlbumListModel *)item];
  self.titleLabel.hidden = YES;
  return cell;
}
@end
