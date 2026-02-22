//
//  NLSongListViewController.m
//  NLSpotify
//
//  Created by 吴桐 on 2026/1/15.
//

#import "NLSongListViewController.h"
#import "NLListCellModel.h"
#import "NLSongListCell.h"
#import "NLSongListHeaderView.h"
#import "NLAlbumService.h"
#import "NLSongListService.h"
#import "NLPlayerManager.h"
#import "NLSong.h"
#import "NLSongService.h"
#import "NLCommentListViewController.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>

@interface NLSongListViewController () <UITableViewDelegate, UITableViewDataSource, NLSongListHeaderViewDelegate>

@property (nonatomic, assign) NSInteger listId;
@property (nonatomic, assign) NLSongListType type;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<NLListCellModel *> *songs;

@property (nonatomic, strong) NLSongListHeaderView *headerView;
@property (nonatomic, strong) NLHeaderModel *header;

@end

@implementation NLSongListViewController

#pragma mark - Init

- (instancetype)initWithId:(NSInteger)listId
                      type:(NLSongListType)type
                      name:(NSString *)name {
    self = [super init];
    if (self) {
        _listId = listId;
        _type = type;
        self.title = name;
        self.songs = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    [self setupNavigationBarAppearance];
    [self.view addSubview:self.tableView];

    [self setupConstraints];
    [self setupNavigation];
    [self requestData];

    __weak typeof(self) weakSelf = self;
    [[NLPlayerManager sharedManager].songSignal subscribeNext:^(NLSong * _Nullable song) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) [strongSelf scrollToCurrentPlayingSong];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self scrollToCurrentPlayingSong];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    // 底部留一半空间，避免被 tabBar 完全挡住
    CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    if (tabBarHeight == 0) {
        tabBarHeight = 49.0 + (self.view.safeAreaInsets.bottom > 0 ? self.view.safeAreaInsets.bottom : 0);
    }
    CGFloat bottomInset = (CGFloat)((NSInteger)(tabBarHeight * 0.5));
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, bottomInset, 0);
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
}

- (void)setupNavigationBarAppearance {
    UINavigationBar *bar = self.navigationController.navigationBar;
    bar.translucent = YES;
    bar.barTintColor = nil;
    bar.backgroundColor = [UIColor clearColor];
    [bar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    bar.shadowImage = [UIImage new];
    bar.tintColor = [UIColor labelColor];
    bar.titleTextAttributes = @{ NSForegroundColorAttributeName: [UIColor labelColor] };
}

- (void)setupNavigation {
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"plus"] style:UIBarButtonItemStylePlain target:self action:@selector(addTapped)];
    UIBarButtonItem *commentItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"text.bubble"] style:UIBarButtonItemStylePlain target:self action:@selector(openCommentTapped)];
    self.navigationItem.rightBarButtonItems = @[ commentItem, addItem ];
}

- (void)addTapped { /* 加入歌单等 */ }

#pragma mark - 评论区入口

- (void)openCommentTapped {
    NLCommentListResourceType type = (self.type == NLSongListTypePlaylist) 
        ? NLCommentListResourceTypePlaylist 
        : NLCommentListResourceTypeAlbum;
    
    NLCommentListViewController *vc = [[NLCommentListViewController alloc] 
        initWithResourceId:self.listId 
              resourceType:type 
                     title:[NSString stringWithFormat:@"%@ 评论", self.title ?: @"评论"]];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Layout

- (void)setupConstraints {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}


- (void)setupTableHeader {
    if (!self.headerView) {
        self.headerView = [[NLSongListHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 570)];
        self.headerView.delegate = self;
    }

    [self.headerView configWithPlayList:self.header];
    [self updateHeaderViewHeight];
}

- (void)updateHeaderViewHeight {
    CGFloat w = self.tableView.bounds.size.width;
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    CGFloat maxH = screenH * 0.75f; // 收起时最大高度限制
    CGFloat largeHeight = 10000.0f; // 布局计算用足够大的高度，确保能正确测量所有内容
    
    // 1. 设置足够大的 bounds，让 Auto Layout 能正确测量
    self.headerView.bounds = CGRectMake(0, 0, w, largeHeight);
    [self.headerView setNeedsLayout];// 强制布局
    [self.headerView layoutIfNeeded];
    
    // 测量实际需要的高度
    CGSize fitSize = [self.headerView systemLayoutSizeFittingSize:CGSizeMake(w, UILayoutFittingCompressedSize.height)];
    CGFloat headerHeight = fitSize.height > 0 ? fitSize.height : maxH;
    
    // 根据展开状态决定是否限制高度
    if (![self.headerView isDescExpanded]) {
        // 收起状态：限制在 3/4 屏高
        headerHeight = (CGFloat)fmin(headerHeight, maxH);
    }
    // 更新 frame 并重新设置 tableHeaderView
    self.headerView.frame = CGRectMake(0, 0, w, headerHeight);
    self.tableView.tableHeaderView = nil;
    self.tableView.tableHeaderView = self.headerView;
    [self.tableView layoutIfNeeded];
}

#pragma mark - Network

- (void)requestData {
    __weak typeof(self) weakSelf = self;
    if (self.type == NLSongListTypeAlbum) {
        [NLAlbumService fetchAlbumDetailWithId:self.listId
                                   completion:^(NLHeaderModel *header,
           NSArray<NLListCellModel *> *songs) {
            [weakSelf handleResponse:header songs:songs];
        }];
    } else {
        [NLSongListService fetchPlayListDetailWithId:self.listId
                                      completion:^(NLHeaderModel *header,
           NSArray<NLListCellModel *> *songs) {
            [weakSelf handleResponse:header songs:songs];
        }];
    }
}

- (void)handleResponse:(NLHeaderModel *)header
                songs:(NSArray<NLListCellModel *> *)songs {
    self.header = header;
    [self.songs removeAllObjects];
    [self.songs addObjectsFromArray:songs];

    [self setupTableHeader];
    [self.tableView reloadData];
    [self scrollToCurrentPlayingSong];
}

- (void)scrollToCurrentPlayingSong {
    if (self.songs.count == 0) return;
    NLSong *currentSong = [NLPlayerManager sharedManager].currentSong;
    if (!currentSong || !currentSong.songId.length) return;
    NSString *currentId = currentSong.songId;
    NSInteger foundIndex = -1;
    for (NSInteger i = 0; i < self.songs.count; i++) {
        if ([[NSString stringWithFormat:@"%ld", (long)self.songs[i].songId] isEqualToString:currentId]) {
            foundIndex = i;
            break;
        }
    }
    if (foundIndex < 0) return;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:foundIndex inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.songs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NLSongListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NLSongCell" forIndexPath:indexPath];
    [cell configWithSong:self.songs[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self playSongAtIndex:indexPath.row];
}

#pragma mark - Playback

// 将 self.songs 转为 NLSong 数组，可选是否打乱顺序
- (NSMutableArray<NLSong *> *)buildSongListShuffled:(BOOL)shuffle {
    NSMutableArray<NLSong *> *list = [NSMutableArray array];
    for (NLListCellModel *model in self.songs) {
        NLSong *song = [NLSong songWithListCellModel:model];
        if (song) [list addObject:song];
    }
    if (shuffle && list.count > 1) {
        for (NSInteger i = list.count - 1; i >= 1; i--) {
            NSInteger j = arc4random_uniform((uint32_t)(i + 1));
            [list exchangeObjectAtIndex:i withObjectAtIndex:j];
        }
    }
    return list;
}

// 拉取指定位置的歌曲播放 URL，然后以该首为起点播放列表
- (void)playSongList:(NSMutableArray<NLSong *> *)songList startIndex:(NSInteger)index {
    if (songList.count == 0 || index < 0 || index >= songList.count) return;
    
    NLSong *startSong = songList[index];
    NSString *songId = startSong.songId;
    if (!songId.length) return;
    
    __weak typeof(self) weakSelf = self;
    [[NLSongService sharedService] fetchPlayableURLWithSongId:songId
                                                    success:^(NSURL *playURL) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            startSong.playURL = playURL;
            [[NLPlayerManager sharedManager] playWithPlaylist:songList startIndex:index];
        });
    } failure:^(NSError *error) {
        NSLog(@"获取播放URL失败: %@", error.localizedDescription);
    }];
}

- (void)playSongAtIndex:(NSInteger)index {
    if (index < 0 || index >= self.songs.count) return;
    
    NSMutableArray<NLSong *> *songList = [self buildSongListShuffled:NO];
    if (songList.count == 0) return;
    
    [self playSongList:songList startIndex:index];
}

#pragma mark - NLSongListHeaderViewDelegate

- (void)headerViewDidTapPlayAll:(NLSongListHeaderView *)headerView {
    NSMutableArray<NLSong *> *songList = [self buildSongListShuffled:NO];
    if (songList.count == 0) return;
    [self playSongList:songList startIndex:0];
}

- (void)headerViewDidTapShuffle:(NLSongListHeaderView *)headerView {
    NSMutableArray<NLSong *> *songList = [self buildSongListShuffled:YES];
    if (songList.count == 0) return;
    [self playSongList:songList startIndex:0];
}


- (void)headerViewDidRequestRelayout:(NLSongListHeaderView *)headerView {
    [self updateHeaderViewHeight];
}

#pragma mark - Getters

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 64;
        _tableView.backgroundColor = [UIColor systemBackgroundColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorColor = [UIColor separatorColor];
        _tableView.separatorInset = UIEdgeInsetsMake(0, 72, 0, 0);
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;

        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 42, 0); // 约为 tabBar 高度的一半，避免挡住内容
        _tableView.scrollIndicatorInsets = _tableView.contentInset;
        [_tableView registerClass:[NLSongListCell class] forCellReuseIdentifier:@"NLSongCell"];
    }
    return _tableView;
}

@end
