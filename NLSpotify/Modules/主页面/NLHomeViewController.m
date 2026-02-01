//
//  NLHomeViewController.m
//  NLSpotify
//
//  Created by 吴桐 on 2025/12/13.
//

#import "NLHomeViewController.h"
#import "NLHomeViewModel.h"
#import "NLSectionViewModel.h"
#import "NLPlayListSmallCell.h"
#import "NLPlayListBigCell.h"
#import "Masonry/Masonry.h"
#import "NLSongListViewController.h"
#import "NLDrawerViewController.h"

@interface NLHomeViewController () <NLDrawerViewControllerDelegate>
@property (nonatomic, strong) NLDrawerViewController *drawerVC;
@property (nonatomic, strong) UIView *drawerDimmingView;
@end

@implementation NLHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self loadData];
    UIImageSymbolConfiguration *symbolConfig = [UIImageSymbolConfiguration configurationWithPointSize:25.0
                                                                                               weight:UIImageSymbolWeightMedium];
    // 设置导航栏上的按钮，左按钮
    UIButton* myImagePhotoBtn = [[UIButton alloc] init];
    [myImagePhotoBtn setImage:[UIImage systemImageNamed:@"person"] forState:UIControlStateNormal];
    myImagePhotoBtn.tintColor = [UIColor systemGreenColor];
    [myImagePhotoBtn setPreferredSymbolConfiguration:symbolConfig forImageInState:UIControlStateNormal];

    // 点击头像按钮
    [myImagePhotoBtn addTarget:self action:@selector(openDrawer) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* myImagePhotoButtonItem = [[UIBarButtonItem alloc]initWithCustomView:myImagePhotoBtn];

    NSArray* titleArr = @[@"All",@"Music",@"Podcast",@"Audiobooks"];

    NSMutableArray* btnArr = [[NSMutableArray alloc] init];
    [btnArr addObject:myImagePhotoButtonItem];

  //  UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
  // 设置tag
    for (int index = 0; index < titleArr.count - 1; index++) {
      NSString *title = titleArr[index];
      UIBarButtonItem* btnItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(pressBtn:)];
      if (index == 0) {
        btnItem.tintColor = [UIColor systemGreenColor];
      }

      btnItem.tag = index + 100;
      [btnArr addObject:btnItem];

    }
    // 全部

    // 音乐

    // 博客

    // 有声书
    self.navigationItem.leftBarButtonItems = btnArr;
  //  self.navigationItem.title = @"主页";
}

- (void)openDrawer {
    if (self.drawerVC) return;
    UIViewController *host = self.navigationController ?: self;
    CGFloat width = host.view.bounds.size.width * 0.78f;
    if (width > 320) width = 320;

    NLDrawerViewController *drawer = [[NLDrawerViewController alloc] init];
    __weak typeof(self) w = self;
    drawer.delegate = self;
    drawer.onRequestClose = ^{
        [w closeDrawer];
    };

    UIView *dimming = [[UIView alloc] initWithFrame:host.view.bounds];
    dimming.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    dimming.alpha = 0;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeDrawer)];
    [dimming addGestureRecognizer:tap];
    dimming.userInteractionEnabled = YES;

    [host addChildViewController:drawer];
    [host.view addSubview:dimming];
    [host.view addSubview:drawer.view];
    [drawer didMoveToParentViewController:host];

    self.drawerVC = drawer;
    self.drawerDimmingView = dimming;

    [dimming mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(host.view);
    }];
    [drawer.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(host.view);
        make.width.mas_equalTo(width);
        make.left.equalTo(host.view.mas_left).offset(-width);
    }];
    [host.view layoutIfNeeded];

    [drawer.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(host.view);
        make.width.mas_equalTo(width);
        make.left.equalTo(host.view.mas_left);
    }];
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        dimming.alpha = 1;
        [host.view layoutIfNeeded];
    } completion:nil];
}

#pragma mark - NLDrawerViewControllerDelegate（抽屉事件接口，可按需实现）

- (void)drawerController:(NLDrawerViewController *)controller didSelectMenuAtIndex:(NSInteger)index {
    // 预留：按菜单项跳转（添加帐号/新增内容/收听统计信息/最近播放/设置和隐私）
    NSLog(@"[Drawer] 菜单项 %ld", (long)index);
}

- (void)drawerControllerDidTapProfile:(NLDrawerViewController *)controller {
    // 预留：跳转个人资料页
    NSLog(@"[Drawer] 点击个人资料");
}

- (void)drawerControllerDidTapStatusButton:(NLDrawerViewController *)controller {
    // 预留：切换动态开关
    NSLog(@"[Drawer] 点击状态按钮");
}

- (void)drawerControllerDidTapNewMessage:(NLDrawerViewController *)controller {
    // 预留：跳转新消息
    NSLog(@"[Drawer] 点击新消息");
}

- (void)closeDrawer {
    if (!self.drawerVC) return;
    UIViewController *host = self.drawerVC.parentViewController;
    NLDrawerViewController *drawer = self.drawerVC;
    UIView *dimming = self.drawerDimmingView;
    CGFloat width = drawer.view.bounds.size.width;

    [drawer.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(host.view);
        make.width.mas_equalTo(width);
        make.left.equalTo(host.view.mas_left).offset(-width);
    }];
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        dimming.alpha = 0;
        [host.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [drawer willMoveToParentViewController:nil];
        [drawer.view removeFromSuperview];
        [drawer removeFromParentViewController];
        [dimming removeFromSuperview];
        self.drawerVC = nil;
        self.drawerDimmingView = nil;
    }];
}

-(void) pressBtn {
    NSLog(@"pressed");
}

- (void)setupUI {
  self.view.backgroundColor = [UIColor blackColor];
//  [self.navigationController setNavigationBarHidden:YES animated:NO];
  self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
  self.tableView.backgroundColor = [UIColor blackColor];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
//  self.tableView.rowHeight = UITableViewAutomaticDimension;
//  self.tableView.estimatedRowHeight = 200;
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  

  [self.view addSubview:self.tableView];

  [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
   // make.top.equalTo(self.view.mas_top).mas_offset(115);
      make.edges.equalTo(self.view);
   // make.left.right.bottom.equalTo(self.view);
  }];

  [self.tableView registerClass:NLPlayListSmallCell.class forCellReuseIdentifier:@"PlayListSmallCell"];
  [self.tableView registerClass:NLPlayListBigCell.class forCellReuseIdentifier:@"PlayListBigCell"];
}

- (void)loadData {
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

    if (sectionVM.style == NLHomeSectionStylePlayListSmall) {

        NLPlayListSmallCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"PlayListSmallCell"
                                        forIndexPath:indexPath];
        [cell configWithSectionVM:sectionVM];
        cell.didSelectPlayList = ^(NLRecommendAlbumListModel *model) {
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) return;
            [self handleSmallPlayListSelected:model];
        };

        return cell;
    }

    if (sectionVM.style == NLHomeSectionStylePlayListBig) {

        NLPlayListBigCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"PlayListBigCell"
                                        forIndexPath:indexPath];
        [cell configWithSectionVM:sectionVM];
        cell.didSelectPlayList = ^(NLSingerAlbumListModel *model) {
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) return;
            [self handleBigPlayListSelected:model];
        };

        return cell;
    }

    return [UITableViewCell new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NLSectionViewModel *sectionVM = [self.homeVM sectionAtIndex:indexPath.section];
    switch (sectionVM.style) {
        case NLHomeSectionStylePlayListSmall:
            return 217;
        case NLHomeSectionStylePlayListBig:
            return 330;
        default:
            return 240;
    }
}


- (void)handleSmallPlayListSelected:(NLRecommendAlbumListModel *)model {
    NSLog(@"[Home] 点击小歌单: %@", model.name);
//    NLListCellController *vc = [[NLListCellController alloc] initWithModelListId:model.playlistId name:model.name];
  //NLHeaderController *vc = [[NLHeaderController alloc] initWithAlbumId:model.playlistId name:model.name];
  NLSongListViewController *vc = [[NLSongListViewController alloc] initWithId:model.playlistId type:NLSongListTypePlaylist name:model.name];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)handleBigPlayListSelected:(NLSingerAlbumListModel *)model {

    NSLog(@"[Home] 点击大歌单: %@", model.title);
//  NLHeaderController *vc = [[NLHeaderController alloc] initWithAlbumId:model.cardId name:model.title];
  NLSongListViewController *vc = [[NLSongListViewController alloc] initWithId:model.cardId type:NLSongListTypeAlbum name:model.title];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - Section 间距控制（非常重要）

- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0.01; // 第一个 section 的 header 高度设为最小，避免顶部空白
    }
    return 10;   // 两个 cell 之间的"上间距"
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



@end
