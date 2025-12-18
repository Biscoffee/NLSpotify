//
//  NLHomeSectionCell.m
//  NLSpotify
//
//  Created by 吴桐 on 2025/12/13.
//
#import "SDWebImage/SDWebImage.h"
#import "NLHomeSectionCell.h"
#import "NLSectionViewModel.h"
#import "Masonry/Masonry.h"
#import "NLSingerAlbumListModel.h"
@interface NLHomeSectionCell () <UICollectionViewDelegate, UICollectionViewDataSource>

@end

@implementation NLHomeSectionCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(nullable NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {

    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:21];
    self.titleLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:self.titleLabel];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 12;
    layout.sectionInset = UIEdgeInsetsMake(0, 16, 0, 16);

    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
      [self.contentView addSubview:self.collectionView];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView).offset(16);
      make.top.equalTo(self.contentView).offset(8);
                make.right.equalTo(self.contentView).offset(-16);
            }];

    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.titleLabel.mas_bottom).offset(12);
                make.left.right.bottom.equalTo(self.contentView);
                //make.height.mas_equalTo(200);
      }];

    self.userAvatar = [[UIImageView alloc] init];
    self.userAvatar.layer.cornerRadius = 18;
    self.userAvatar.clipsToBounds = YES;
    self.userAvatar.backgroundColor = [UIColor lightGrayColor]; 
    [self.contentView addSubview: _userAvatar];

    self.labelSmall = [[UILabel alloc] init];
    self.labelSmall.font = [UIFont systemFontOfSize:12];
    self.labelSmall.textColor = [UIColor lightGrayColor];
    self.labelSmall.text = @"的粉丝特供";
    [self.contentView addSubview:self.labelSmall];

    self.userName = [[UILabel alloc] init];
    self.userName.font = [UIFont boldSystemFontOfSize:16];
    self.userName.textColor = UIColor.whiteColor;
    self.userName.text = @"用户名";
    [self.contentView addSubview:self.userName];

    [self.userAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self.contentView).offset(16);
        make.width.height.mas_equalTo(36);
    }];

    [self.labelSmall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.userAvatar.mas_top);
        make.left.equalTo(self.userAvatar.mas_right).offset(16);
        make.right.equalTo(self.contentView).offset(-16);
    }];

    [self.userName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.labelSmall.mas_bottom).offset(2);
        make.left.equalTo(self.labelSmall.mas_left);
        make.right.equalTo(self.contentView).offset(-16);
    }];
  }
  return self;
}

- (void)configWithSectionVM:(nonnull NLSectionViewModel *)sectionVM {
  self.sectionVM = sectionVM;
  self.titleLabel.text = sectionVM.title;

  if (sectionVM.style == NLHomeSectionStylePlayListBig) {
          NLSingerAlbumListModel *firstModel = sectionVM.items.firstObject;
    NSLog(@"sdfuisdhfgviusd%@ %@", firstModel.singer,  firstModel.singerUrl);
          [self.userAvatar sd_setImageWithURL:[NSURL URLWithString:firstModel.singerUrl]];
          self.userName.text = firstModel.singer;
      }
  [self registerCollectionCells];
  [self.collectionView reloadData];
}



- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return self.sectionVM.items.count;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
  id item = self.sectionVM.items[indexPath.item];
  return [self configureCollectionCell:collectionView indexPath:indexPath item:item];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  return [self sizeForCollectionCell];
}

- (void)registerCollectionCells {
  NSAssert(NO, @"子类必须实现registerCollectionCells方法");
}

- (CGSize)sizeForCollectionCell {
  NSAssert(NO, @"子类必须实现sizeForCollectionCell方法");
  return CGSizeZero;
}

- (UICollectionViewCell *)configureCollectionCell:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath item:(id)item {
  NSAssert(NO, @"子类必须实现configureCollectionCell方法");
  return nil;
}
@end
