//  NLMusicPlayerViewController.m
//  NLSpotify
//
//  Created by 吴桐 on 2025/12/19.
//

#import "NLMusicPlayerViewController.h"
#import "NLMusicPlayerView.h"
#import "NLPlayerManager.h"
#import "NLCacheManager.h"
#import "NLSong.h"
#import "NLSongRepository.h"
#import "NLPlayListRepository.h"
#import "NLAddToPlaylistSheetViewController.h"
#import "NLCommentListViewController.h"
#import "NLDownloadManager.h"
#import <Masonry/Masonry.h>

@interface NLMusicPlayerViewController () <NLMusicPlayerViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIView *backgroundOverlay;
@property (nonatomic, strong) NLMusicPlayerView *playerView;
@end

@implementation NLMusicPlayerViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];

    [self.view addSubview:self.backgroundOverlay];
    [self.view addSubview:self.playerView];
    [self setupConstraints];

    [self bindPlayer];
    [self refreshUI];

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    pan.delegate = self;
    pan.minimumNumberOfTouches = 1;
    pan.maximumNumberOfTouches = 1;
    [self.view addGestureRecognizer:pan];
}

- (void)setupConstraints {
    [self.backgroundOverlay mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - Player Binding

- (void)bindPlayer {
//    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
//    [center addObserver:self selector:@selector(refreshUI)
//                   name:NLPlayerSongDidChangeNotification object:nil];
//    [center addObserver:self selector:@selector(refreshPlayState)
//                   name:NLPlayerPlaybackStateDidChangeNotification object:nil];
//    [center addObserver:self selector:@selector(playerProgressDidChange:)
//                   name:NLPlayerProgressDidChangeNotification object:nil];
        NLPlayerManager *manager = NLPlayerManager.sharedManager;
        @weakify(self);
    // 等价于__weak typeof(self) weakSelf = self;
    //  歌曲信息变化
        [manager.songSignal subscribeNext:^(NLSong *song) {
            @strongify(self);
            if (!song) return;
            [self.playerView updateTitle:song.title artist:song.artist];
            [self.playerView updateCoverURL:song.coverURL];
            [self.playerView updateProgress:0];
            [self.playerView updateCacheProgress:0];
            [self.playerView updateCurrentTime:0 totalTime:manager.totalTime];
            [self.playerView updateFavoriteState:[NLSongRepository isSongLiked:song.songId]];
            if (self.playerView.isQueuePanelVisible) {
                [self.playerView reloadQueue];
            }
        }];

    //  播放状态变化
        [manager.playbackStateSignal subscribeNext:^(NSNumber *stateNum) {
            @strongify(self);
            BOOL playing = stateNum.integerValue == NLPlaybackStatePlaying;
            [self.playerView updatePlayState:playing];
        }];

    // 播放进度
        [manager.progressSignal subscribeNext:^(NSNumber *progressNum) {
            @strongify(self);
            if (self.playerView.isTrackingProgress) return;

            float progress = progressNum.floatValue;
            [self.playerView updateProgress:progress];
            [self.playerView updateCurrentTime:manager.currentTime
                                     totalTime:manager.totalTime];
        }];

    // 缓存进度
        [manager.cacheProgressSignal subscribeNext:^(NSNumber *progressNum) {
            @strongify(self);
            if ([progressNum isKindOfClass:[NSNumber class]]) {
                [self.playerView updateCacheProgress:progressNum.floatValue];
            }
        }];
}


- (void)refreshUI {
    NLSong *song = NLPlayerManager.sharedManager.currentSong;
    if (!song) {
        [self.playerView updateTitle:@"未在播放" artist:@""];
        [self.playerView updateCoverURL:nil];
    [self.playerView updateProgress:0];
    [self.playerView updateCacheProgress:0];
    [self.playerView updateCurrentTime:0 totalTime:0];
    [self.playerView updateFavoriteState:NO];
        return;
    }
    [self.playerView updateTitle:song.title artist:song.artist];
    [self.playerView updateCoverURL:song.coverURL];
    float progress = NLPlayerManager.sharedManager.currentProgress;
    [self.playerView updateProgress:progress];
    NSURL *url = song.playURL;
    float cacheProgress = url ? [[NLCacheManager sharedManager] cacheProgressForURL:url] : 0.f;
    NSLog(@"[缓存条] refreshUI 设置缓存条 progress=%.2f url=%@", cacheProgress, url.absoluteString ?: @"");
    [self.playerView updateCacheProgress:cacheProgress];

    NSTimeInterval currentTime = NLPlayerManager.sharedManager.currentTime;
    NSTimeInterval totalTime = NLPlayerManager.sharedManager.totalTime;
    [self.playerView updateCurrentTime:currentTime totalTime:totalTime];
    
    [self.playerView updateVolume:NLPlayerManager.sharedManager.volume];
    BOOL playing = NLPlayerManager.sharedManager.playbackState == NLPlaybackStatePlaying;
    [self.playerView updatePlayState:playing];
    [self.playerView updatePlayMode:NLPlayerManager.sharedManager.playMode];
    [self.playerView updateFavoriteState:[NLSongRepository isSongLiked:song.songId]];
}


#pragma mark -  Delegate

- (void)musicPlayerViewDidTapClose:(NLMusicPlayerView *)view {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)musicPlayerViewDidTapPlayPause:(NLMusicPlayerView *)view {
    [NLPlayerManager.sharedManager togglePlayPause];
}

- (void)musicPlayerViewDidTapPrevious:(NLMusicPlayerView *)view {
    [NLPlayerManager.sharedManager playPrevious];
}

- (void)musicPlayerViewDidTapNext:(NLMusicPlayerView *)view {
    [NLPlayerManager.sharedManager playNext];
}

- (void)musicPlayerView:(NLMusicPlayerView *)view didChangeProgress:(float)value {
    [[NLPlayerManager sharedManager] seekToProgress:value];
}

- (void)musicPlayerView:(NLMusicPlayerView *)view didChangeVolume:(float)value {
    [NLPlayerManager sharedManager].volume = value;
}

- (void)musicPlayerViewDidTapComment:(NLMusicPlayerView *)view {
    NLSong *song = NLPlayerManager.sharedManager.currentSong;
    if (!song || !song.songId.length) return;
    NSInteger songId = [song.songId integerValue];
    if (songId <= 0) return;
    NLCommentListViewController *commentVC = [[NLCommentListViewController alloc] initWithResourceId:songId resourceType:NLCommentListResourceTypeSong title:[NSString stringWithFormat:@"%@ 评论", song.title ?: @"歌曲"]];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:commentVC];
    nav.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)musicPlayerViewDidTapPlaylist:(NLMusicPlayerView *)view {
    [view setQueuePanelVisible:!view.isQueuePanelVisible animated:YES];
}

- (NSArray<NLSong *> *)musicPlayerViewPlaylist:(NLMusicPlayerView *)view {
    return NLPlayerManager.sharedManager.playlist ?: @[];
}

- (NSInteger)musicPlayerViewCurrentIndex:(NLMusicPlayerView *)view {
    return NLPlayerManager.sharedManager.currentIndex;
}

- (void)musicPlayerView:(NLMusicPlayerView *)view didSelectSongAtIndex:(NSInteger)index {
    [[NLPlayerManager sharedManager] playSongAtIndex:index];
    [view reloadQueue];
}

- (void)musicPlayerView:(NLMusicPlayerView *)view didChangePlayMode:(NLPlayMode)playMode {
    [view updatePlayMode:playMode];
    [NLPlayerManager.sharedManager setPlayMode:playMode];
}

- (void)musicPlayerViewDidTapAddToPlaylist:(NLMusicPlayerView *)view {
    NLSong *song = [NLPlayerManager sharedManager].currentSong;
    if (!song || !song.songId.length) return;

    NLAddToPlaylistSheetViewController *vc = [[NLAddToPlaylistSheetViewController alloc] init];
    vc.currentSong = song;
    [self presentViewController:vc animated:NO completion:nil];
}

- (void)musicPlayerViewDidTapFavorite:(NLMusicPlayerView *)view {
    NLSong *song = [NLPlayerManager sharedManager].currentSong;
    if (!song || !song.songId.length) return;
    BOOL currentlyLiked = [NLSongRepository isSongLiked:song.songId];
    BOOL newLiked = !currentlyLiked;
    [NLSongRepository likeSong:song isLike:newLiked];
    [view updateFavoriteState:newLiked];
}

- (void)musicPlayerViewDidTapMore:(NLMusicPlayerView *)view {
    NLSong *song = [NLPlayerManager sharedManager].currentSong;
    if (!song || !song.songId.length) return;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"下载" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NLDownloadManager sharedManager] addDownloadForSong:song];
        [self showToast:@"已加入下载"];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        alert.popoverPresentationController.sourceView = view;
        alert.popoverPresentationController.sourceRect = CGRectMake(view.bounds.size.width - 60, 80, 1, 1);
    }
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showToast:(NSString *)text {
    UIView *toast = [[UIView alloc] init];
    toast.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75];
    toast.layer.cornerRadius = 10;
    toast.alpha = 0;
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = [UIColor whiteColor];
    [toast addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(toast).insets(UIEdgeInsetsMake(12, 20, 12, 20));
    }];
    [self.view addSubview:toast];
    [toast mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
    [UIView animateWithDuration:0.2 animations:^{ toast.alpha = 1; }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25 animations:^{ toast.alpha = 0; } completion:^(BOOL finished) {
            [toast removeFromSuperview];
        }];
    });
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // 如果触摸点在 slider 或其父视图上，不响应 pan 手势
    UIView *touchView = touch.view;
    
    // 检查触摸的视图是否是 slider 或其子视图
    if ([touchView isKindOfClass:[UISlider class]]) {
        return NO; // 直接触摸 slider，不响应 pan 手势
    }
    
    // 检查触摸点是否在 slider 的区域内（扩大检查范围）
    CGPoint touchPoint = [touch locationInView:self.playerView];
    UIView *progressSlider = self.playerView.progressSlider;
    UIView *volumeSlider = self.playerView.volumeSlider;
    
    // 将 slider 的 frame 转换到 playerView 的坐标系
    CGRect progressFrame = [progressSlider.superview convertRect:progressSlider.frame toView:self.playerView];
    CGRect volumeFrame = [volumeSlider.superview convertRect:volumeSlider.frame toView:self.playerView];
    CGRect expandedProgressFrame = CGRectInset(progressFrame, -10, -30);
    CGRect expandedVolumeFrame = CGRectInset(volumeFrame, -10, -30);
    
    if (CGRectContainsPoint(expandedProgressFrame, touchPoint) || CGRectContainsPoint(expandedVolumeFrame, touchPoint)) {
        return NO; // 触摸点在 slider 区域内，不响应 pan 手势
    }
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    // 如果是 pan 手势，检查初始触摸点和滑动方向
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint location = [pan locationInView:self.playerView];
        CGPoint translation = [pan translationInView:self.view];
        
        // 检查是否在 slider 区域内
        UIView *progressSlider = self.playerView.progressSlider;
        UIView *volumeSlider = self.playerView.volumeSlider;
        
        CGRect progressFrame = [progressSlider.superview convertRect:progressSlider.frame toView:self.playerView];
        CGRect volumeFrame = [volumeSlider.superview convertRect:volumeSlider.frame toView:self.playerView];
        
        // 扩大检查范围
        CGRect expandedProgressFrame = CGRectInset(progressFrame, -20, -40);
        CGRect expandedVolumeFrame = CGRectInset(volumeFrame, -20, -40);
        
        if (CGRectContainsPoint(expandedProgressFrame, location) || CGRectContainsPoint(expandedVolumeFrame, location)) {
            // 如果在 slider 区域，且是水平滑动，不开始 pan 手势
            if (fabs(translation.x) > fabs(translation.y)) {
                return NO; // 水平滑动，让 slider 处理
            }
            // 即使是垂直滑动，如果在 slider 区域，也不响应（避免误触）
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    // 如果另一个手势是 slider 的手势，不同时识别
    if ([otherGestureRecognizer.view isKindOfClass:[UISlider class]]) {
        return NO;
    }
    return NO;
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    CGPoint translation = [pan translationInView:self.view];
    CGPoint velocity = [pan velocityInView:self.view];
    
    // 只处理向下滑动
    if (translation.y < 0) {
        // 如果向上滑动，重置状态
        if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateCancelled) {
            [self resetDismissAnimation];
        }
        return;
    }
    
    // 计算下滑进度（使用更大的阈值，使交互更流畅）
    CGFloat dismissThreshold = 400.0;
    CGFloat progress = MIN(translation.y / dismissThreshold, 1.0);
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        // 开始下滑时，可以添加触觉反馈
        if (@available(iOS 10.0, *)) {
            UIImpactFeedbackGenerator *feedback = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
            [feedback impactOccurred];
        }
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        // 更新视图位置和进度
        self.view.transform = CGAffineTransformMakeTranslation(0, translation.y);
        self.playerView.dismissProgress = progress;
        
        // 在下拉过程中逐渐显示背景（让后面的页面可见）
        // 通过调整背景层的透明度，让后面的页面逐渐显示
        UIView *backgroundOverlay = self.backgroundOverlay;
        if (backgroundOverlay) {
            backgroundOverlay.alpha = 1.0 - progress; // 下拉时背景层逐渐透明
        }
    } else if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateCancelled) {
        // 判断是否应该关闭：进度超过阈值或向下速度足够快
        BOOL shouldDismiss = progress > 0.3 || velocity.y > 500;
        
        if (shouldDismiss) {
            // 关闭播放器
            [self dismissWithAnimation:progress];
        } else {
            // 恢复原状
            [self resetDismissAnimation];
        }
    }
}

- (void)dismissWithAnimation:(CGFloat)progress {
    // 计算剩余距离
    CGFloat remainingDistance = self.view.bounds.size.height - self.view.transform.ty;
    
    // 根据剩余距离和速度计算动画时长
    CGFloat duration = MIN(remainingDistance / 800.0, 0.4);
    
    UIView *backgroundOverlay = self.backgroundOverlay;
    [UIView animateWithDuration:duration
                          delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0, self.view.bounds.size.height);
        self.playerView.dismissProgress = 1.0;
        if (backgroundOverlay) {
            backgroundOverlay.alpha = 0.0; // 完全透明，显示后面的页面
        }
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (void)resetDismissAnimation {
    UIView *backgroundOverlay = self.backgroundOverlay;
    [UIView animateWithDuration:0.3
                          delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        self.view.transform = CGAffineTransformIdentity;
        self.playerView.dismissProgress = 0.0;
        if (backgroundOverlay) {
            backgroundOverlay.alpha = 1.0; // 恢复不透明
        }
    } completion:nil];
}

//- (void)dealloc {
//    [NSNotificationCenter.defaultCenter removeObserver:self];
//}

#pragma mark - Getters

- (UIView *)backgroundOverlay {
    if (!_backgroundOverlay) {
        _backgroundOverlay = [[UIView alloc] init];
        // 使用稍微深一点的背景色，避免纯白
        if (@available(iOS 13.0, *)) {
            _backgroundOverlay.backgroundColor = [UIColor secondarySystemBackgroundColor];
        } else {
            _backgroundOverlay.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
        }
        _backgroundOverlay.tag = 999;
    }
    return _backgroundOverlay;
}

- (NLMusicPlayerView *)playerView {
    if (!_playerView) {
        _playerView = [[NLMusicPlayerView alloc] initWithFrame:CGRectZero];
        _playerView.delegate = self;
    }
    return _playerView;
}

@end
