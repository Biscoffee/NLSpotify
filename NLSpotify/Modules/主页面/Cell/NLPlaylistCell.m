//
//  NLPlaylistCell.m
//  NLSpotify
//
#import "SDWebImage/SDWebImage.h"
#import "NLPlaylistCell.h"
#import "NLSectionViewModel.h"
#import "NLRecommendAlbumListModel.h"
#import "Masonry/Masonry.h"

@implementation PlaylistCollectionCell

-(id) initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.coverImgView = [[UIImageView alloc] init];
    self.coverImgView.contentMode = UIViewContentModeScaleAspectFill;
    self.coverImgView.clipsToBounds = YES;
    self.coverImgView.layer.cornerRadius = 8;
    self.coverImgView.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentView.backgroundColor = UIColor.clearColor;
    [self.contentView addSubview:self.coverImgView];

    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.font = [UIFont systemFontOfSize:14];
    self.nameLabel.numberOfLines = 2;
    self.nameLabel.textColor = [UIColor labelColor];
    self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.nameLabel];

    [self.coverImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self.contentView).offset(4);
        make.height.mas_equalTo(120);
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.coverImgView.mas_bottom).offset(4);
        make.leading.trailing.bottom.equalTo(self.contentView);
    }];
    self.contentView.backgroundColor = UIColor.clearColor;
  }
  return self;
}

- (void)configWithModel:(NLRecommendAlbumListModel *)model {
      self.nameLabel.text = model.name;
  NSString *picUrl = model.picUrl;
  if (picUrl && picUrl.length > 0) {
      picUrl = [picUrl stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"];
      picUrl = [picUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
  }
  [self.coverImgView sd_setImageWithURL:[NSURL URLWithString: picUrl]
                         placeholderImage:[UIImage imageNamed:@"placeholder"]];
}

@end

@implementation NLPlaylistCell

-(void) registerCollectionCells {
  [self.collectionView registerClass:PlaylistCollectionCell.class forCellWithReuseIdentifier:@"PlaylistCollectionCell"];
  self.collectionView.backgroundColor = [UIColor systemBackgroundColor];
  self.contentView.backgroundColor = [UIColor systemBackgroundColor];
  self.backgroundColor = [UIColor systemBackgroundColor];
}

-(CGSize)sizeForCollectionCell {
  return CGSizeMake(120, 180);
}

- (UICollectionViewCell *)configureCollectionCell:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath item:(id)item {
  PlaylistCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PlaylistCollectionCell" forIndexPath:indexPath];
  [cell configWithModel:(NLRecommendAlbumListModel *)item];
  self.titleLabel.hidden = NO;
  return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  NLRecommendAlbumListModel *model = self.sectionVM.items[indexPath.item];
  if (self.didSelectPlaylist) {
    self.didSelectPlaylist(model);
  }
}

@end
