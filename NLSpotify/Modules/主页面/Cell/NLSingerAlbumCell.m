//
//  NLSingerAlbumCell.m
//  NLSpotify
//

#import "NLSingerAlbumCell.h"
#import "NLSectionViewModel.h"
#import "Masonry/Masonry.h"
#import "NLSingerAlbumListModel.h"
#import "SDWebImage/SDWebImage.h"

@interface NLSingerAlbumCell ()
@property (nonatomic, strong, readwrite) UIImageView *userAvatar;
@property (nonatomic, strong, readwrite) UILabel *labelSmall;
@property (nonatomic, strong, readwrite) UILabel *userName;
@end

@implementation SingerAlbumCollectionCell
{

  UIImageView *_coverImageView;//歌单封面
  UIImageView *_spotifyIconView;//spotify logo
  UILabel *_titleLabel;//歌单标题
  UILabel *_subtitleLabel;//歌单描述
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = UIColor.clearColor;

        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.layer.cornerRadius = 14;
        _coverImageView.clipsToBounds = YES;
        [self.contentView addSubview:_coverImageView];

        _spotifyIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"spotify.png"]];
        [_coverImageView addSubview:_spotifyIconView];

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:15];
        _titleLabel.textColor = [UIColor labelColor];
        [self.contentView addSubview:_titleLabel];

        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.font = [UIFont systemFontOfSize:13];
        _subtitleLabel.textColor = [UIColor secondaryLabelColor];
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
    _titleLabel.text = model.title;
    _subtitleLabel.text = model.subtitle;
}

@end



@implementation NLSingerAlbumCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.titleLabel.hidden = YES;

        _userAvatar = [[UIImageView alloc] init];
        _userAvatar.layer.cornerRadius = 18;
        _userAvatar.clipsToBounds = YES;
        _userAvatar.backgroundColor = [UIColor tertiarySystemFillColor];
        [self.contentView addSubview:_userAvatar];

        _labelSmall = [[UILabel alloc] init];
        _labelSmall.font = [UIFont systemFontOfSize:12];
        _labelSmall.textColor = [UIColor secondaryLabelColor];
        _labelSmall.text = @"的粉丝特供";
        [self.contentView addSubview:_labelSmall];

        _userName = [[UILabel alloc] init];
        _userName.font = [UIFont boldSystemFontOfSize:16];
        _userName.textColor = [UIColor labelColor];
        _userName.text = @"用户名";
        [self.contentView addSubview:_userName];

        [_userAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(self.contentView).offset(16);
            make.width.height.mas_equalTo(36);
        }];

        [_labelSmall mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_userAvatar.mas_top);
            make.left.equalTo(_userAvatar.mas_right).offset(16);
            make.right.equalTo(self.contentView).offset(-16);
        }];

        [_userName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_labelSmall.mas_bottom).offset(2);
            make.left.equalTo(_labelSmall.mas_left);
            make.right.equalTo(self.contentView).offset(-16);
        }];

        [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_userName.mas_bottom).offset(12);
            make.left.right.bottom.equalTo(self.contentView);
            make.height.mas_equalTo(0);
        }];
    }
    return self;
}

- (void)configWithSectionVM:(NLSectionViewModel *)sectionVM {
    [super configWithSectionVM:sectionVM];
    if (sectionVM.style != NLHomeSectionStyleSingerAlbum || sectionVM.items.count == 0) return;
    NLSingerAlbumListModel *first = (NLSingerAlbumListModel *)sectionVM.items.firstObject;
    [_userAvatar sd_setImageWithURL:[NSURL URLWithString:first.singerUrl]];
    _userName.text = first.singer;
}

- (void)registerCollectionCells {
  [self.collectionView registerClass:SingerAlbumCollectionCell.class forCellWithReuseIdentifier:@"SingerAlbumCollectionCell"];
  self.collectionView.backgroundColor = [UIColor systemBackgroundColor];
  self.contentView.backgroundColor = [UIColor systemBackgroundColor];
  self.backgroundColor = [UIColor systemBackgroundColor];
  self.titleLabel.textColor = [UIColor labelColor];
}

- (CGSize)sizeForCollectionCell {
  return CGSizeMake(200, 280);
}

- (UICollectionViewCell *)configureCollectionCell:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath item:(id)item {
  SingerAlbumCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SingerAlbumCollectionCell" forIndexPath:indexPath];
  [cell configWithModel:(NLSingerAlbumListModel *)item];
  self.titleLabel.hidden = YES;
  return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  NLSingerAlbumListModel *model = self.sectionVM.items[indexPath.item];
  if (self.didSelectSingerAlbum) {
    self.didSelectSingerAlbum(model);
  }
}
@end
