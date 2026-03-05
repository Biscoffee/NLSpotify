//
//  NLHomeSectionCell.m
//  NLSpotify
//
//  Created by 吴桐 on 2025/12/13.
//
#import "NLHomeSectionCell.h"
#import "NLSectionViewModel.h"
#import "Masonry/Masonry.h"

@interface NLHomeSectionCell () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, assign) CGFloat collectionViewExpandedHeight; // 展开时 collectionView 高度，用于高度自适应
@end

@implementation NLHomeSectionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(nullable NSString *)reuseIdentifier {
      self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
      if (self) {
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

        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.contentView);
            make.height.mas_equalTo(0); // 不 pin bottom，避免与 TableView 给的 contentView 高度冲突
        }];
          [self registerCollectionCells];
      }
      return self;
}

/*
 重写属性setter
 */
- (void)setCollapsed:(BOOL)collapsed {
    _collapsed = collapsed;
    self.collectionView.hidden = collapsed;
    CGFloat h = collapsed ? 0 : self.collectionViewExpandedHeight;
    [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(h);
    }];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)configWithSectionVM:(nonnull NLSectionViewModel *)sectionVM {
  self.sectionVM = sectionVM;
  self.collectionViewExpandedHeight = [self sizeForCollectionCell].height;
  [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
      make.height.mas_equalTo(self.collapsed ? 0 : self.collectionViewExpandedHeight);
  }];
  [self.collectionView reloadData];
}

#pragma mark - UICollectionView

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
