//
//  NLMusicLibraryListViewController.m
//  NLSpotify
//

#import "NLMusicLibraryListViewController.h"
#import "NLSongRepository.h"
#import "NLPlayListRepository.h"
#import "NLAlbumRepository.h"
#import "NLSong.h"
#import "NLPlayList.h"
#import "NLAlbum.h"
#import "NLSongListCell.h"
#import "NLSongListViewController.h"
#import "NLCreatePlayListSheetViewController.h"
#import "NLPlayerManager.h"
#import "NLSongService.h"
#import <Masonry/Masonry.h>

static NSString * const kCellId = @"MusicLibraryCell";

@interface NLMusicLibraryListViewController () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>
@property (nonatomic, assign) NLMusicLibraryListMode mode;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *emptyStateView;
@property (nonatomic, copy) NSArray<NLSong *> *songs;
@property (nonatomic, copy) NSArray<NLPlayList *> *playlists;
@property (nonatomic, copy) NSArray<NLAlbum *> *albums;
@end

@implementation NLMusicLibraryListViewController

- (instancetype)initWithMode:(NLMusicLibraryListMode)mode {
    if (self = [super init]) {
        _mode = mode;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.navigationItem.title = [self titleForMode:self.mode];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"chevron.left"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(backTapped)];

    if (self.mode == NLMusicLibraryListModeMyPlaylists) {
        UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                  target:self
                                                                                  action:@selector(addTapped)];
        self.navigationItem.rightBarButtonItem = addItem;
    }

    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;

    [self.view addSubview:self.tableView];
    [self.view addSubview:self.emptyStateView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.emptyStateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.left.greaterThanOrEqualTo(self.view.mas_left).offset(24);
        make.right.lessThanOrEqualTo(self.view.mas_right).offset(-24);
    }];

    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadData];
}

- (void)backTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addTapped {
    NLCreatePlayListSheetViewController *vc = [[NLCreatePlayListSheetViewController alloc] init];
    __weak typeof(self) weakSelf = self;
    vc.completion = ^(NSString *name) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;
        NLPlayList *playList = [NLPlayListRepository createUserPlayListWithName:name];
        if (playList) {
            [self loadData];
        }
    };
    [self presentViewController:vc animated:YES completion:nil];
}

- (NSString *)titleForMode:(NLMusicLibraryListMode)mode {
    switch (mode) {
        case NLMusicLibraryListModeRecentPlay:     return @"播放历史";
        case NLMusicLibraryListModeLikedPlaylists: return @"收藏的歌单";
        case NLMusicLibraryListModeMyPlaylists:    return @"创建的歌单";
        case NLMusicLibraryListModeLikedAlbums:    return @"我收藏的专辑";
        case NLMusicLibraryListModeLikedSongs:     return @"我喜欢的歌曲";
    }
}

- (void)loadData {
    switch (self.mode) {
        case NLMusicLibraryListModeRecentPlay: {
            NSArray<NLSong *> *history = [NLSongRepository allPlayHistory];
            self.songs = [[[history reverseObjectEnumerator] allObjects] copy];
            self.playlists = nil;
            self.albums = nil;
            break;
        }
        case NLMusicLibraryListModeLikedSongs: {
            self.songs = [NLSongRepository allLikedSongs];
            self.playlists = nil;
            self.albums = nil;
            break;
        }
        case NLMusicLibraryListModeLikedPlaylists: {
            self.songs = nil;
            self.playlists = [NLPlayListRepository allLikedPlayLists];
            self.albums = nil;
            break;
        }
        case NLMusicLibraryListModeMyPlaylists: {
            self.songs = nil;
            self.playlists = [NLPlayListRepository allUserCreatedPlayLists];
            self.albums = nil;
            break;
        }
        case NLMusicLibraryListModeLikedAlbums: {
            self.songs = nil;
            self.playlists = nil;
            self.albums = [NLAlbumRepository allLikedAlbums];
            break;
        }
    }
    [self.tableView reloadData];
    BOOL hasItems = [self rowCount] > 0;
    self.emptyStateView.hidden = hasItems;
}

- (BOOL)isSongMode {
    return self.mode == NLMusicLibraryListModeRecentPlay || self.mode == NLMusicLibraryListModeLikedSongs;
}

- (BOOL)isAlbumMode {
    return self.mode == NLMusicLibraryListModeLikedAlbums;
}

- (NSInteger)rowCount {
    if ([self isSongMode]) return (NSInteger)self.songs.count;
    if ([self isAlbumMode]) return (NSInteger)self.albums.count;
    return (NSInteger)self.playlists.count;
}

#pragma mark - UITableViewDataSource / Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self rowCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NLSongListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId forIndexPath:indexPath];
    if ([self isSongMode]) {
        [cell configWithNLSong:self.songs[indexPath.row]];
    } else if ([self isAlbumMode]) {
        [cell configWithAlbum:self.albums[indexPath.row]];
    } else {
        [cell configWithPlayList:self.playlists[indexPath.row]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self isSongMode]) {
        NLSong *song = self.songs[indexPath.row];
        if (!song.songId.length) return;
        NSMutableArray<NLSong *> *list = [self.songs mutableCopy];
        NSInteger startIndex = indexPath.row;
        [[NLSongService sharedService] fetchPlayableURLWithSongId:song.songId
                                                         success:^(NSURL *playURL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (startIndex < (NSInteger)list.count) list[startIndex].playURL = playURL;
                [[NLPlayerManager sharedManager] playWithPlaylist:list startIndex:startIndex];
            });
        } failure:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"获取播放链接失败 %@", error.localizedDescription);
            });
        }];
        return;
    }
    if ([self isAlbumMode]) {
        NLAlbum *album = self.albums[indexPath.row];
        if (!album.albumId.length) return;
        NSInteger albumId = [album.albumId integerValue];
        if (albumId <= 0) return;
        NLSongListViewController *vc = [[NLSongListViewController alloc] initWithId:albumId
                                                                               type:NLSongListTypeAlbum
                                                                               name:album.name ?: @""];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    NLPlayList *list = self.playlists[indexPath.row];
    if (!list.playlistId.length) return;
    NSCharacterSet *nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    BOOL isNumeric = ([list.playlistId rangeOfCharacterFromSet:nonDigits].location == NSNotFound);
    NLSongListViewController *vc;
    if (isNumeric && [list.playlistId integerValue] > 0) {
        vc = [[NLSongListViewController alloc] initWithId:[list.playlistId integerValue]
                                                    type:NLSongListTypePlaylist
                                                    name:list.name ?: @""];
    } else {
        vc = [[NLSongListViewController alloc] initWithLocalPlayList:list];
    }
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle != UITableViewCellEditingStyleDelete) return;
    if ([self isSongMode]) {
        NLSong *song = self.songs[indexPath.row];
        if (self.mode == NLMusicLibraryListModeRecentPlay) {
            [NLSongRepository removePlayHistoryWithSongId:song.songId];
        } else {
            [NLSongRepository likeSong:song isLike:NO];
        }
        NSMutableArray *mutable = [self.songs mutableCopy];
        [mutable removeObjectAtIndex:indexPath.row];
        self.songs = [mutable copy];
    } else if ([self isAlbumMode]) {
        NLAlbum *album = self.albums[indexPath.row];
        [NLAlbumRepository setAlbum:album liked:NO];
        NSMutableArray *mutable = [self.albums mutableCopy];
        [mutable removeObjectAtIndex:indexPath.row];
        self.albums = [mutable copy];
    } else {
        NLPlayList *list = self.playlists[indexPath.row];
        if (self.mode == NLMusicLibraryListModeLikedPlaylists) {
            [NLPlayListRepository setPlayList:list liked:NO];
        } else {
            [NLPlayListRepository deletePlayList:list.playlistId];
        }
        NSMutableArray *mutable = [self.playlists mutableCopy];
        [mutable removeObjectAtIndex:indexPath.row];
        self.playlists = [mutable copy];
    }
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    self.emptyStateView.hidden = [self rowCount] > 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.navigationController.interactivePopGestureRecognizer) {
        if (self.navigationController.viewControllers.count <= 1) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - Getters

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor systemBackgroundColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorInset = UIEdgeInsetsMake(0, 76, 0, 0);
        _tableView.tableFooterView = [UIView new];
        [_tableView registerClass:[NLSongListCell class] forCellReuseIdentifier:kCellId];
    }
    return _tableView;
}

- (UIView *)emptyStateView {
    if (!_emptyStateView) {
        _emptyStateView = [[UIView alloc] init];
        NSString *iconName = @"music.note.list";
        NSString *text = @"暂无内容";
        switch (self.mode) {
            case NLMusicLibraryListModeRecentPlay:
                iconName = @"clock.arrow.circlepath";
                text = @"最近播放的歌曲将在这里显示。";
                break;
            case NLMusicLibraryListModeLikedSongs:
                iconName = @"heart";
                text = @"收藏的歌曲将在这里显示。在播放器中点击星星即可收藏。";
                break;
            case NLMusicLibraryListModeLikedPlaylists:
                iconName = @"star.circle";
                text = @"收藏的歌单会显示在这里。在歌单页面点右上角星星即可收藏。";
                break;
            case NLMusicLibraryListModeMyPlaylists:
                iconName = @"folder.badge.plus";
                text = @"还没有自建歌单。点击右上角加号创建歌单。";
                break;
            case NLMusicLibraryListModeLikedAlbums:
                iconName = @"square.stack";
                text = @"收藏的专辑会显示在这里。在专辑详情页点右上角星星即可收藏。";
                break;
        }
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:64 weight:UIImageSymbolWeightLight];
        UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:iconName withConfiguration:config]];
        iconView.tintColor = [UIColor tertiaryLabelColor];
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        [_emptyStateView addSubview:iconView];

        UILabel *label = [[UILabel alloc] init];
        label.text = text;
        label.font = [UIFont systemFontOfSize:16];
        label.textColor = [UIColor tertiaryLabelColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        [_emptyStateView addSubview:label];

        [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.centerX.equalTo(_emptyStateView);
            make.size.mas_equalTo(CGSizeMake(80, 80));
        }];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(iconView.mas_bottom).offset(16);
            make.left.right.bottom.equalTo(_emptyStateView);
        }];
    }
    return _emptyStateView;
}

@end
