//
//  NLPlayListViewController.m
//  NLSpotify
//
//  Created by 吴桐 on 2026/1/17.
//
#import "NLPlaylistViewController.h"
#import "NLPlaylistService.h"
#import "NLPlaylistCollectionCell.h"
#import <Masonry/Masonry.h>
#import "NLCategoryModel.h"
#import "NLSongListViewController.h"

@interface NLPlaylistViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray<NLPlaylistModel *> *playlists;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation NLPlaylistViewController

- (instancetype)initWithCategoryModel:(NLCategoryModel *)model {
    self = [super init];
    if (self) {
        _categoryModel = model;
        _categoryName = model.name;
        _playlists = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];
    [self setupNavigation];
    [self loadData];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor blackColor];

    // 标题
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.text = self.categoryName;
    _titleLabel.font = [UIFont boldSystemFontOfSize:24];
    _titleLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:_titleLabel];

    // 创建布局
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 16;
    layout.minimumInteritemSpacing = 16;
    CGFloat itemWidth = (self.view.bounds.size.width - 48) / 2; // 左右各16，中间间距16
    layout.itemSize = CGSizeMake(itemWidth, itemWidth + 60); // 高度为宽度+标题和创建者的高度

    // 创建集合视图
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.backgroundColor = [UIColor clearColor];
    [_collectionView registerClass:[NLPlaylistCollectionCell class] forCellWithReuseIdentifier:@"PlaylistCollectionCell"];
    [self.view addSubview:_collectionView];

    // 加载指示器
    _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _loadingIndicator.hidesWhenStopped = YES;
    [self.view addSubview:_loadingIndicator];

    // 布局
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(20);
        make.left.equalTo(self.view).offset(16);
        make.right.equalTo(self.view).offset(-16);
    }];

    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleLabel.mas_bottom).offset(20);
        make.left.equalTo(self.view).offset(16);
        make.right.equalTo(self.view).offset(-16);
        make.bottom.equalTo(self.view);
    }];

    [_loadingIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
}

- (void)setupNavigation {
    // 自定义返回按钮
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage systemImageNamed:@"chevron.left"] forState:UIControlStateNormal];
    [backButton setTintColor:[UIColor whiteColor]];
    [backButton addTarget:self action:@selector(backButtonTapped) forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backItem;
}

- (void)loadData {
    [_loadingIndicator startAnimating];

    __weak typeof(self) weakSelf = self;
    [NLPlaylistService fetchPlaylistsWithCategory:self.categoryName success:^(NSArray<NLPlaylistModel *> *playlists) {
        [weakSelf.loadingIndicator stopAnimating];
        weakSelf.playlists = [playlists mutableCopy];
        [weakSelf.collectionView reloadData];
      if (playlists.count > 0) {
          NLPlaylistModel *first = playlists.firstObject;

          // 回写到 CategoryModel（你需要在初始化 VC 时传 model，而不是只传 name）
          self.categoryModel.previewCoverUrl = first.coverImgUrl;
      }
        if (playlists.count == 0) {
            [weakSelf showEmptyView];
        }
    } failure:^(NSError *error) {
        [weakSelf.loadingIndicator stopAnimating];
        [weakSelf showError:error.localizedDescription];
    }];
}

- (void)showError:(NSString *)errorMessage {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误"
                                                                   message:errorMessage
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *retry = [UIAlertAction actionWithTitle:@"重试" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self loadData];
    }];

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];

    [alert addAction:retry];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showEmptyView {
    UILabel *emptyLabel = [[UILabel alloc] init];
    emptyLabel.text = @"暂无歌单数据";
    emptyLabel.textColor = [UIColor lightGrayColor];
    emptyLabel.textAlignment = NSTextAlignmentCenter;
    emptyLabel.font = [UIFont systemFontOfSize:16];

    self.collectionView.backgroundView = emptyLabel;
}

- (void)backButtonTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.playlists.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NLPlaylistCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PlaylistCollectionCell" forIndexPath:indexPath];
    cell.playlist = self.playlists[indexPath.item];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    NLPlaylistModel *playlist = self.playlists[indexPath.item];

    NLSongListViewController *vc =
        [[NLSongListViewController alloc]
            initWithId:playlist.playlistId
            type:NLSongListTypePlaylist
            name:playlist.name];

    [self.navigationController pushViewController:vc animated:YES];
}

@end
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

