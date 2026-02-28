//
//  NLMusicViewController.m
//  NLSpotify
//
//  Created by 吴桐 on 2025/12/14.
//

#import "NLMusicViewController.h"
#import "NLMusicLibraryListViewController.h"
#import "Masonry/Masonry.h"

@interface NLMusicViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray<NSDictionary<NSString *, NSString *> *> *menuItems;
@end

@implementation NLMusicViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.navigationItem.title = @"音乐库";

    self.menuItems = @[
        @{@"title": @"播放历史",         @"icon": @"clock.arrow.circlepath"},
        @{@"title": @"收藏的歌单",       @"icon": @"star.circle"},
        @{@"title": @"创建的歌单",       @"icon": @"music.note.list"},
        @{@"title": @"缓存",             @"icon": @"arrow.down.circle"},
        @{@"title": @"我下载的音乐",     @"icon": @"arrow.down.circle.fill"},
        @{@"title": @"艺人",             @"icon": @"mic"},
        @{@"title": @"我收藏的专辑",     @"icon": @"square.stack"},
        @{@"title": @"歌曲",             @"icon": @"music.note"}
    ];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - UITableViewDataSource

// 单组列表
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"MusicLibraryMenuCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSDictionary *item = self.menuItems[indexPath.row];
    cell.textLabel.text = item[@"title"];
    UIImage *icon = [UIImage systemImageNamed:item[@"icon"]];
    cell.imageView.image = icon;
    cell.imageView.tintColor = [UIColor systemRedColor];
    cell.textLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightRegular];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NLMusicLibraryListViewController *vc = nil;
    switch (indexPath.row) {
        case 0: vc = [[NLMusicLibraryListViewController alloc] initWithMode:NLMusicLibraryListModeRecentPlay]; break;
        case 1: vc = [[NLMusicLibraryListViewController alloc] initWithMode:NLMusicLibraryListModeLikedPlaylists]; break;
        case 2: vc = [[NLMusicLibraryListViewController alloc] initWithMode:NLMusicLibraryListModeMyPlaylists]; break;
        case 3: vc = [[NLMusicLibraryListViewController alloc] initWithMode:NLMusicLibraryListModeCachedSongs]; break;
        case 4: vc = [[NLMusicLibraryListViewController alloc] initWithMode:NLMusicLibraryListModeDownloadedSongs]; break;
        case 6: vc = [[NLMusicLibraryListViewController alloc] initWithMode:NLMusicLibraryListModeLikedAlbums]; break;
        case 7: vc = [[NLMusicLibraryListViewController alloc] initWithMode:NLMusicLibraryListModeLikedSongs]; break;
        default: break; // 5 = 艺人，暂无列表页
    }
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Getters

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor systemBackgroundColor];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

@end

