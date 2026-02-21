//
//  NLHomeSectionCell.m
//  NLSpotify
//
//  Created by 吴桐 on 2025/12/13.
//
#import "NLHomeSectionCell.h"
#import "NLSectionViewModel.h"
#import "Masonry/Masonry.h"

@interface NLHomeSectionCell () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UIButton *headerTapButton;
@property (nonatomic, strong) UIImageView *disclosureImageView;
@property (nonatomic, assign) CGFloat collectionViewExpandedHeight; // 展开时 collectionView 高度，用于高度自适应
@end

@implementation NLHomeSectionCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(nullable NSString *)reuseIdentifier {
      self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
      if (self) {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:21];
        self.titleLabel.textColor = [UIColor labelColor];
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
                    make.bottom.greaterThanOrEqualTo(self.contentView.mas_top).offset(40); // 折叠时 self-sizing：40+12+0≈52
                }];

        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.titleLabel.mas_bottom).offset(12);
                    make.left.right.bottom.equalTo(self.contentView);
                    make.height.mas_equalTo(0); // 在 config 中按子类 sizeForCollectionCell 更新
          }];

        // 标题区点击按钮（用于折叠/展开）
        self.headerTapButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.headerTapButton.backgroundColor = UIColor.clearColor;
        [self.headerTapButton addTarget:self action:@selector(headerTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.headerTapButton];
        [self.headerTapButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.contentView);
            make.height.mas_equalTo(52);
        }];

        // 折叠指示箭头
        self.disclosureImageView = [[UIImageView alloc] init];
        UIImage *chevronDown = [UIImage systemImageNamed:@"chevron.down"];
        //UIImage *chevronUp = [UIImage systemImageNamed:@"chevron.up"];
        if (chevronDown) {
            self.disclosureImageView.image = [chevronDown imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
        self.disclosureImageView.tintColor = [UIColor secondaryLabelColor];
        self.disclosureImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.disclosureImageView];
        [self.disclosureImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.headerTapButton);
            make.right.equalTo(self.contentView).offset(-16);
            make.width.height.mas_equalTo(20);
        }];
      }
      return self;
}

- (void)headerTapped {
    if (self.didTapHeader) self.didTapHeader(self.sectionIndex);
}

- (void)setCollapsed:(BOOL)collapsed {
    _collapsed = collapsed;
    self.collectionView.hidden = collapsed;
    CGFloat h = collapsed ? 0 : self.collectionViewExpandedHeight;
    [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(h);
    }];
    UIImage *img = collapsed ? [UIImage systemImageNamed:@"chevron.down"] : [UIImage systemImageNamed:@"chevron.up"];
    if (img) self.disclosureImageView.image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (void)configWithSectionVM:(nonnull NLSectionViewModel *)sectionVM {
  self.sectionVM = sectionVM;
  self.titleLabel.text = sectionVM.title;
  [self registerCollectionCells];
  self.collectionViewExpandedHeight = [self sizeForCollectionCell].height;
  [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
      make.height.mas_equalTo(self.collapsed ? 0 : self.collectionViewExpandedHeight);
  }];
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
