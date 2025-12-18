//
//  NLPlayListSmallCell.m
//  NLSpotify
//
//  Created by 吴桐 on 2025/12/13.
//
#import "SDWebImage/SDWebImage.h"
#import "NLPlayListSmallCell.h"
#import "NLSectionViewModel.h"
#import "NLRecommendAlbumListModel.h"
#import "Masonry/Masonry.h"

@implementation PlayListSmallCollectionCell

-(id) initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.coverImgView = [[UIImageView alloc] init];
    self.coverImgView.contentMode = UIViewContentModeScaleAspectFill;
    self.coverImgView.clipsToBounds = YES;
    self.coverImgView.layer.cornerRadius = 8;
    self.coverImgView.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentView.backgroundColor = [UIColor blackColor];
    [self.contentView addSubview:self.coverImgView];

    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.font = [UIFont systemFontOfSize:14];
    self.nameLabel.numberOfLines = 2;
    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.nameLabel];

    [self.coverImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self.contentView).offset(4);
        make.height.mas_equalTo(120);
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.coverImgView.mas_bottom).offset(4);
        make.leading.trailing.bottom.equalTo(self.contentView);
        //make.height.mas_greaterThanOrEqualTo(20);
      //make.bottom.equalTo(self.contentView.mas_bottom);
    }];
    self.contentView.backgroundColor = UIColor.blackColor;
  }
  return self;
}

- (void)configWithModel:(NLRecommendAlbumListModel *)model {
      self.nameLabel.text = model.name;
  NSString *picUrl = model.picUrl;
  if (picUrl && picUrl.length > 0) {
      picUrl = [picUrl stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"];
      // 处理URL中的特殊字符（避免格式错误）
      picUrl = [picUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
  }
  [self.coverImgView sd_setImageWithURL:[NSURL URLWithString: picUrl]
                         placeholderImage:[UIImage imageNamed:@"placeholder"]];
}

@end

@implementation NLPlayListSmallCell

-(void) registerCollectionCells {
  [self.collectionView registerClass:PlayListSmallCollectionCell.class forCellWithReuseIdentifier:@"PlayListSmallCollectionCell"];
  self.collectionView.backgroundColor = [UIColor blackColor];
  self.contentView.backgroundColor = [UIColor blackColor];
  self.backgroundColor = [UIColor blackColor];
}

-(CGSize)sizeForCollectionCell {
  return CGSizeMake(120, 180);
}

- (UICollectionViewCell *)configureCollectionCell:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath item:(id)item {
  PlayListSmallCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PlayListSmallCollectionCell" forIndexPath:indexPath];
  [cell configWithModel:(NLRecommendAlbumListModel *)item];
  self.titleLabel.hidden = NO;
  self.userAvatar.hidden = YES;
  self.labelSmall.hidden = YES;
  self.userName.hidden = YES;
  return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  NLRecommendAlbumListModel *model = self.sectionVM.items[indexPath.item];
  if (self.didSelectPlayList) {
    self.didSelectPlayList(model);
  }
}

@end
