//
//  NLSearchViewController.m
//  NLSpotify
//
//  Created by 吴桐 on 2025/12/14.
//

#import "NLSearchViewController.h"
#import "NLDiscoveryCardModel.h"
#import "NLCategoryModel.h"
#import "NLDiscoveryCardCell.h"
#import "NLCategoryCell.h"
#import <Masonry/Masonry.h>
#import "NLPlaylistViewController.h"
#import "NLSearchResultViewController.h"
#import "NLPlaylistService.h"

@interface NLSearchViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;

// 发现新内容
@property (nonatomic, strong) UILabel *discoveryTitleLabel;
@property (nonatomic, strong) UICollectionView *discoveryCollectionView;
@property (nonatomic, strong) NSArray<NLDiscoveryCardModel *> *discoveryCards;

// 浏览全部
@property (nonatomic, strong) UILabel *browseTitleLabel;
@property (nonatomic, strong) UICollectionView *categoryCollectionView;
@property (nonatomic, strong) NSArray<NLCategoryModel *> *categories;
@property (nonatomic, strong) UISearchController *searchController;

@property (nonatomic, assign) BOOL presentingResult;

@end

@implementation NLSearchViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  self.title = @"搜索";
  self.view.backgroundColor = UIColor.blackColor;
  self.navigationItem.searchController = self.searchController;

  self.searchController = [[UISearchController alloc] init];
  self.navigationItem.searchController = self.searchController;
  self.definesPresentationContext = YES;
  if (self.searchController.active) {
    [self.searchController setActive:NO];
  }
    [self setupData];
    [self setupUI];
    [self setupConstraints];
  
}

- (void)setupSearchController {
  // 这里的 searchController 仅作为入口展示
      UISearchController *sc = [[UISearchController alloc] initWithSearchResultsController:nil];
      sc.searchBar.delegate = self;
      sc.searchBar.placeholder = @"艺人、歌曲、歌词以及更多内容";
      sc.searchBar.searchBarStyle = UISearchBarStyleMinimal;
      sc.hidesNavigationBarDuringPresentation = NO;

      // 关键：不显示取消按钮，符合图1样式
      sc.automaticallyShowsCancelButton = NO;

      self.searchController = sc;
      self.navigationItem.searchController = sc;
      self.navigationItem.hidesSearchBarWhenScrolling = NO;
      self.definesPresentationContext = YES;

      // iOS 18+ 强制搜索框位置（如果需要像图1那样在底部，可以使用 Stacked）
      if (@available(iOS 18.0, *)) {
          self.navigationItem.preferredSearchBarPlacement = UINavigationItemSearchBarPlacementStacked;
      }
  self.navigationItem.hidesSearchBarWhenScrolling = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 重置presentingResult状态，允许再次进入result页面
    self.presentingResult = NO;
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    // 拦截点击：跳转到结果页，而不是在当前页搜索
    NLSearchResultViewController *resultVC = [[NLSearchResultViewController alloc] init];
    [self.navigationController pushViewController:resultVC animated:YES];
    return NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    // 在 SearchVC 中不需要处理取消按钮，因为不会显示
    [searchBar resignFirstResponder];
}

#pragma mark - Data

- (void)setupData {
    self.discoveryCards = [NLDiscoveryCardModel defaultDiscoveryCards];
    self.categories = [NLCategoryModel defaultCategories];
    [self fetchCategoryPreviews];
}

- (void)fetchCategoryPreviews {
    __weak typeof(self) weakSelf = self;
    [self.categories enumerateObjectsUsingBlock:^(NLCategoryModel *model, NSUInteger idx, BOOL *stop) {
        [NLPlaylistService fetchPlaylistsWithCategory:model.name
                                              success:^(NSArray<NLPlaylistModel *> *playlists) {
            if (playlists.count > 0) {
                NLPlaylistModel *first = playlists.firstObject;
                model.previewCoverUrl = first.coverImgUrl;
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:0];
                    [weakSelf.categoryCollectionView reloadItemsAtIndexPaths:@[indexPath]];
                });
            }
        } failure:nil];
    }];
}

#pragma mark - UI Setup

- (void)setupUI {
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_scrollView];

    _contentView = [[UIView alloc] init];
    [_scrollView addSubview:_contentView];

    [self setupDiscoveryArea];
    [self setupBrowseArea];
}

- (void)setupDiscoveryArea {
    _discoveryTitleLabel = [[UILabel alloc] init];
    _discoveryTitleLabel.text = @"发现新内容";
    _discoveryTitleLabel.font = [UIFont boldSystemFontOfSize:20];
    _discoveryTitleLabel.textColor = [UIColor labelColor];
    [_contentView addSubview:_discoveryTitleLabel];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 12;
    layout.itemSize = CGSizeMake(220, 140);
    layout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);

    _discoveryCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _discoveryCollectionView.backgroundColor = [UIColor clearColor];
    _discoveryCollectionView.showsHorizontalScrollIndicator = NO;
    _discoveryCollectionView.dataSource = self;
    _discoveryCollectionView.delegate = self;
    [_discoveryCollectionView registerClass:[NLDiscoveryCardCell class] forCellWithReuseIdentifier:@"DiscoveryCardCell"];
    [_contentView addSubview:_discoveryCollectionView];

    [_discoveryTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_contentView).offset(24);
        make.left.equalTo(_contentView).offset(20);
    }];

    [_discoveryCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_discoveryTitleLabel.mas_bottom).offset(12);
        make.left.right.equalTo(_contentView);
        make.height.mas_equalTo(160);
    }];
}

- (void)setupBrowseArea {
    _browseTitleLabel = [[UILabel alloc] init];
    _browseTitleLabel.text = @"浏览全部";
    _browseTitleLabel.font = [UIFont boldSystemFontOfSize:20];
    _browseTitleLabel.textColor = [UIColor labelColor];
    [_contentView addSubview:_browseTitleLabel];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 12;
    layout.minimumInteritemSpacing = 12;
    layout.itemSize = CGSizeMake((self.view.bounds.size.width - 52) / 2, 105);

    _categoryCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _categoryCollectionView.backgroundColor = [UIColor clearColor];
    _categoryCollectionView.scrollEnabled = NO;
    _categoryCollectionView.dataSource = self;
    _categoryCollectionView.delegate = self;
    [_categoryCollectionView registerClass:[NLCategoryCell class] forCellWithReuseIdentifier:@"CategoryCell"];
    [_contentView addSubview:_categoryCollectionView];

    [_browseTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_discoveryCollectionView.mas_bottom).offset(20);
        make.left.equalTo(_contentView).offset(20);
    }];

    [_categoryCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_browseTitleLabel.mas_bottom).offset(12);
        make.left.equalTo(_contentView).offset(20);
        make.right.equalTo(_contentView).offset(-20);
        make.height.mas_equalTo([self calculateCategoryCollectionHeight]);
        make.bottom.equalTo(_contentView).offset(-30);
    }];
}

- (void)setupConstraints {
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_scrollView);
        make.width.equalTo(_scrollView);
    }];
}

- (CGFloat)calculateCategoryCollectionHeight {
    NSInteger rows = (self.categories.count + 1) / 2;
    return rows * 105 + (rows - 1) * 12;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == _discoveryCollectionView) return self.discoveryCards.count;
    return self.categories.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _discoveryCollectionView) {
        NLDiscoveryCardCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DiscoveryCardCell" forIndexPath:indexPath];
        cell.model = self.discoveryCards[indexPath.item];
        return cell;
    } else {
        NLCategoryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CategoryCell" forIndexPath:indexPath];
        cell.model = self.categories[indexPath.item];
        return cell;
    }
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _discoveryCollectionView) {
        NLDiscoveryCardModel *model = self.discoveryCards[indexPath.item];
        NSLog(@"发现卡片被点击: %@", model.title);
    } else {
        NLCategoryModel *model = self.categories[indexPath.item];
        NLPlaylistViewController *vc = [[NLPlaylistViewController alloc] initWithCategoryModel:model];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _discoveryCollectionView) return CGSizeMake(220, 140);
    CGFloat width = (collectionView.bounds.size.width - 12) / 2;
    return CGSizeMake(width, 105);
}

@end
