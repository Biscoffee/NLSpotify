//
//  NLSongListViewController.m
//  NLSpotify
//
//  Created by 吴桐 on 2026/1/15.
//

#import "NLSongListViewController.h"
#import "SDWebImage/SDWebImage.h"
#import "NLListCellModel.h"
#import "NLSongListCell.h"
#import "NLSongListHeaderView.h"
#import "NLAlbumService.h"
#import "NLSongListServiece.h"
#import "NLPlayerManager.h"
#import "NLSong.h"
#import "NLSongService.h"

@interface NLSongListViewController ()
<UITableViewDelegate,
UITableViewDataSource,
NLSongListHeaderViewDelegate>

@property (nonatomic, assign) NSInteger listId;
@property (nonatomic, assign) NLSongListType type;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<NLListCellModel *> *songs;

// Header
@property (nonatomic, strong) NLSongListHeaderView *headerView;
@property (nonatomic, strong) NLHeaderModel *header;

// 背景
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIVisualEffectView *blurView;
@property (nonatomic, strong) UIView *darkMaskView;

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

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.clearColor;
  self.navigationController.navigationBar.barTintColor = [UIColor clearColor];

    [self setupBackground];
    [self setupTableView];
    [self requestData];
}

#pragma mark - UI Setup

- (void)setupBackground {
    self.bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.bgImageView.clipsToBounds = YES;
    [self.view addSubview:self.bgImageView];

    self.blurView = [[UIVisualEffectView alloc]
        initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    self.blurView.frame = self.view.bounds;
    [self.view addSubview:self.blurView];

    self.darkMaskView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.darkMaskView.backgroundColor =
        [[UIColor blackColor] colorWithAlphaComponent:0.35];
    [self.view addSubview:self.darkMaskView];
}

- (void)setupTableView {
    self.tableView =
        [[UITableView alloc] initWithFrame:self.view.bounds
                                     style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 60;
    self.tableView.backgroundColor = UIColor.clearColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // 修复内容重合问题：确保 contentInset 正确
    self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.tableView.contentInset = UIEdgeInsetsZero;

    [self.tableView registerClass:[NLSongListCell class]
           forCellReuseIdentifier:@"NLSongCell"];

    [self.view addSubview:self.tableView];
}

- (void)setupTableHeader {
    if (!self.headerView) {
        // 使用固定高度，确保内容不重合
        // 封面顶部120（从80增加到120） + 封面160 + 间距16 + 标题估算44 + 间距8 + 描述估算44 + 间距14 + 作者32 + 间距24 + 按钮44 + 底部间距20
        CGFloat headerHeight = 120 + 160 + 16 + 44 + 8 + 44 + 14 + 32 + 24 + 44 + 20; // 约520（从480增加到520）
        
        self.headerView =
            [[NLSongListHeaderView alloc]
                initWithFrame:CGRectMake(0, 0,
                                         self.view.bounds.size.width,
                                         headerHeight)];
        self.headerView.delegate = self;
    }

    [self.headerView configWithPlayList:self.header];
    
    // 确保 headerView 有正确的 frame，避免内容重合
    [self.headerView layoutIfNeeded]; // 先布局，让约束生效
    CGFloat headerHeight = self.headerView.frame.size.height;
    if (headerHeight <= 0) {
        // 如果高度计算失败，使用固定高度
        headerHeight = 480;
    }
    
    // 重新设置 frame 和 tableHeaderView，确保高度正确
    self.headerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, headerHeight);
    self.tableView.tableHeaderView = nil; // 先清空
    self.tableView.tableHeaderView = self.headerView; // 重新设置
    
    // 强制更新 table view 的布局
    [self.tableView layoutIfNeeded];
}

#pragma mark - Network

- (void)requestData {
    __weak typeof(self) weakSelf = self;

    if (self.type == NLSongListTypeAlbum) {
        [NLAlbumService fetchAlbumDetailWithId:self.listId
                                   completion:
         ^(NLHeaderModel *header,
           NSArray<NLListCellModel *> *songs) {
            [weakSelf handleResponse:header songs:songs];
        }];
    } else {
        [NLSongListServiece fetchPlayListDetailWithId:self.listId
                                      completion:
         ^(NLHeaderModel *header,
           NSArray<NLListCellModel *> *songs) {
            [weakSelf handleResponse:header songs:songs];
        }];
    }
}

- (void)handleResponse:(NLHeaderModel *)header
                songs:(NSArray<NLListCellModel *> *)songs {

    self.header = header;
    [self.bgImageView sd_setImageWithURL:
        [NSURL URLWithString:header.coverUrl]];

    [self.songs removeAllObjects];
    [self.songs addObjectsFromArray:songs];

    [self setupTableHeader];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.songs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NLSongListCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"NLSongCell"
                                        forIndexPath:indexPath];
    [cell configWithSong:self.songs[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NLListCellModel *songModel = self.songs[indexPath.row];
    [self playSongAtIndex:indexPath.row];
}


#pragma mark - Playback

- (void)playSongAtIndex:(NSInteger)index {
    if (index < 0 || index >= self.songs.count) {
        return;
    }
    // 简化：使用便捷方法将整个歌单转换为NLSong数组（使用ListCellModel的封面数据）
    NSMutableArray<NLSong *> *songList = [NSMutableArray array];
    for (NLListCellModel *model in self.songs) {
        NLSong *song = [NLSong songWithListCellModel:model];
        if (song) {
            [songList addObject:song];
        }
    }
    if (songList.count == 0) {
        return;
    }
    // 获取当前选中歌曲的播放URL
    NLListCellModel *currentModel = self.songs[index];
    NSString *songId = [NSString stringWithFormat:@"%ld", (long)currentModel.songId];
    NLSong *currentSong = songList[index];

    __weak typeof(self) weakSelf = self;
    [[NLSongService sharedService] fetchPlayableURLWithSongId:songId
                                                    success:^(NSURL *playURL) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            // 设置播放URL并开始播放
            currentSong.playURL = playURL;
            [[NLPlayerManager sharedManager] playWithPlaylist:songList startIndex:index];
        });
    } failure:^(NSError *error) {
        NSLog(@"获取播放URL失败: %@", error.localizedDescription);
    }];
}

#pragma mark - NLSongListHeaderViewDelegate

- (void)headerViewDidTapPlayAll:(NLSongListHeaderView *)headerView {
    NSLog(@"▶️ 播放全部");
}

- (void)headerViewDidTapDownload:(NLSongListHeaderView *)headerView {
    NSLog(@"⬇️ 下载");
}

- (void)headerViewDidTapSort:(NLSongListHeaderView *)headerView {
    NSLog(@"↕️ 排序");
}

- (void)headerView:(NLSongListHeaderView *)headerView
  didTapTopAction:(NSString *)type {
    NSLog(@"🔘 顶部按钮：%@", type);
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
