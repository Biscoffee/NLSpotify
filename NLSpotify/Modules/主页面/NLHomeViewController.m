//
//  NLHomeViewController.m
//  NLSpotify
//
//  Created by 吴桐 on 2025/12/13.
//

#import "NLHomeViewController.h"
#import "NLHomeViewModel.h"
#import "NLSectionViewModel.h"
#import "NLPlaylistCell.h"
#import "NLSingerAlbumCell.h"
#import "Masonry/Masonry.h"
#import "NLSongListViewController.h"
#import "NLDrawerViewController.h"

@interface NLHomeViewController () <NLDrawerViewControllerDelegate>
@property (nonatomic, strong) NLDrawerViewController *drawerVC;
@property (nonatomic, strong) NSMutableSet<NSNumber *> *collapsedSections;
@end

@implementation NLHomeViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.collapsedSections = [NSMutableSet set];

    [self.view addSubview:self.tableView];
    [self setupConstraints];
    [self setupNavigation];
    [self loadData];
}

- (void)pressBtn:(id)sender {
    NSLog(@"Bar button tapped");
}

- (void)openDrawer {
    if (self.drawerVC) return;
    NLDrawerViewController *drawer = [[NLDrawerViewController alloc] init];
    drawer.delegate = self;
    __weak typeof(self) w = self;
    drawer.onDidDismiss = ^{
        w.drawerVC = nil;
    };
    self.drawerVC = drawer;
    [drawer presentFromHostViewController:self.navigationController ?: self];
}

#pragma mark - NLDrawerViewControllerDelegate

- (void)drawerController:(NLDrawerViewController *)controller didSelectMenuAtIndex:(NSInteger)index {
    NSLog(@"[Drawer] 菜单项 %ld", (long)index);
}

- (void)drawerControllerDidTapProfile:(NLDrawerViewController *)controller {
    NSLog(@"[Drawer] 点击个人资料");
}

- (void)drawerControllerDidTapStatusButton:(NLDrawerViewController *)controller {
    NSLog(@"[Drawer] 点击状态按钮");
}

- (void)drawerControllerDidTapNewMessage:(NLDrawerViewController *)controller {
    NSLog(@"[Drawer] 点击新消息");
}

#pragma mark - Layout & Data

- (void)setupNavigation {
    UIImageSymbolConfiguration *symbolConfig = [UIImageSymbolConfiguration configurationWithPointSize:25.0 weight:UIImageSymbolWeightMedium];
    UIButton *myImagePhotoBtn = [[UIButton alloc] init];
    [myImagePhotoBtn setImage:[UIImage systemImageNamed:@"person"] forState:UIControlStateNormal];
    myImagePhotoBtn.tintColor = [UIColor systemGreenColor];
    [myImagePhotoBtn setPreferredSymbolConfiguration:symbolConfig forImageInState:UIControlStateNormal];
    [myImagePhotoBtn addTarget:self action:@selector(openDrawer) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *myImagePhotoButtonItem = [[UIBarButtonItem alloc] initWithCustomView:myImagePhotoBtn];

    NSArray *titleArr = @[@"All", @"Music", @"Podcast", @"Audiobooks"];
    NSMutableArray *btnArr = [NSMutableArray arrayWithObject:myImagePhotoButtonItem];
    for (NSInteger index = 0; index < titleArr.count - 1; index++) {
        NSString *title = titleArr[index];
        UIBarButtonItem *btnItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(pressBtn:)];
        if (index == 0) btnItem.tintColor = [UIColor systemGreenColor];
        btnItem.tag = index + 100;
        [btnArr addObject:btnItem];
    }
    self.navigationItem.leftBarButtonItems = btnArr;
}

- (void)setupConstraints {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)loadData {
    if (!self.collapsedSections) self.collapsedSections = [NSMutableSet set];
    self.homeVM = [[NLHomeViewModel alloc] init];
    __weak typeof(self) weakself = self;
    [self.homeVM loadDataWithCompletion:^{
        __strong typeof(weakself) self = weakself;
        if (!self) return;
        [self.tableView reloadData];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.homeVM numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NLSectionViewModel *sectionVM =
    [self.homeVM sectionAtIndex:indexPath.section];
    __weak typeof(self) weakSelf = self;

    if (sectionVM.style == NLHomeSectionStylePlaylist) {

        NLPlaylistCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"PlaylistCell"
                                        forIndexPath:indexPath];
        [cell configWithSectionVM:sectionVM];
        cell.sectionIndex = indexPath.section;
        cell.collapsed = [self.collapsedSections containsObject:@(indexPath.section)];
        cell.didTapHeader = ^(NSInteger sectionIndex) {
            __strong typeof(weakSelf) self = weakSelf;
            if (self) [self toggleSectionCollapsed:sectionIndex];
        };
        cell.didSelectPlaylist = ^(NLRecommendAlbumListModel *model) {
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) return;
            [self handlePlaylistSelected:model];
        };

        return cell;
    }

    if (sectionVM.style == NLHomeSectionStyleSingerAlbum) {

        NLSingerAlbumCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"SingerAlbumCell"
                                        forIndexPath:indexPath];
        [cell configWithSectionVM:sectionVM];
        cell.sectionIndex = indexPath.section;
        cell.collapsed = [self.collapsedSections containsObject:@(indexPath.section)];
        cell.didTapHeader = ^(NSInteger sectionIndex) {
            __strong typeof(weakSelf) self = weakSelf;
            if (self) [self toggleSectionCollapsed:sectionIndex];
        };
        cell.didSelectSingerAlbum = ^(NLSingerAlbumListModel *model) {
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) return;
            [self handleSingerAlbumSelected:model];
        };

        return cell;
    }

    return [UITableViewCell new];
}

//点击标题后的该行：折叠变展开，展开变折叠，然后重新刷新这一行
- (void)toggleSectionCollapsed:(NSInteger)section {
    if (section < 0) return;
    NSNumber *key = @(section);
    if ([self.collapsedSections containsObject:key]) {
        [self.collapsedSections removeObject:key];
    } else {
        [self.collapsedSections addObject:key];
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}


- (void)handlePlaylistSelected:(NLRecommendAlbumListModel *)model {
    NSLog(@"[Home] 点击小歌单: %@", model.name);
    NLSongListViewController *vc = [[NLSongListViewController alloc] initWithId:model.playlistId type:NLSongListTypePlaylist name:model.name];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)handleSingerAlbumSelected:(NLSingerAlbumListModel *)model {

    NSLog(@"[Home] 点击歌手专辑: %@", model.title);
    NLSongListViewController *vc = [[NLSongListViewController alloc] initWithId:model.cardId type:NLSongListTypeAlbum name:model.title];
    [self.navigationController pushViewController:vc animated:YES];
}


- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0.01;
    }
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForFooterInSection:(NSInteger)section {
    return 0.01; // 必须 >0，否则 grouped 会给默认高度
}

- (UIView *)tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}

- (UIView *)tableView:(UITableView *)tableView
viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

#pragma mark - Getters

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 220;
        [_tableView registerClass:NLPlaylistCell.class forCellReuseIdentifier:@"PlaylistCell"];
        [_tableView registerClass:NLSingerAlbumCell.class forCellReuseIdentifier:@"SingerAlbumCell"];
    }
    return _tableView;
}

@end
