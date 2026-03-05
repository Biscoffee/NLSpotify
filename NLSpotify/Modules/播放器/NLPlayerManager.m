//  NLPlayerManager.m
//  NLSpotify
//
//  Created by 吴桐 on 2026/1/18.
//

#import "NLPlayerManager.h"
#import <AVFoundation/AVFoundation.h>
#import "NLSongService.h"
#import "NLSongRepository.h"
#import "SDWebImage/SDWebImage.h"
#import "NLResourceLoader.h"
#import "NLCacheManager.h"


//NSString * const NLPlayerSongDidChangeNotification = @"NLPlayerSongDidChangeNotification";//  歌曲换了，用于通知刷新UI
//NSString * const NLPlayerPlaybackStateDidChangeNotification = @"NLPlayerPlaybackStateDidChangeNotification";//  播放/暂停/加载中 时候发送通知，用于更新播放的按钮
//NSString * const NLPlayerProgressDidChangeNotification = @"NLPlayerProgressDidChangeNotification";//  用于通知进度的变化

static void *kPlayerCurrentItemStatusContext = &kPlayerCurrentItemStatusContext;

@interface NLPlayerManager ()
@property (nonatomic, strong, readwrite) NLSong *currentSong;
@property (nonatomic, assign, readwrite) NLPlaybackState playbackState;
@property (nonatomic, strong, readwrite) NSArray<NLSong *> *playlist;
@property (nonatomic, assign, readwrite) NSInteger currentIndex;
@property (nonatomic, assign, readwrite) NLPlayMode playMode;
@property (nonatomic, strong) AVPlayer *player;   //音乐播放器
@property (nonatomic, strong) AVPlayerItem *currentPlayerItem;
@property (nonatomic, strong) RACSubject<NSNumber *> *playbackStateSubject;
@property (nonatomic, strong) RACSubject<NLSong *> *songSubject;
@property (nonatomic, strong) RACSubject<NSNumber *> *progressSubject;
@property (nonatomic, strong) RACSubject<NSNumber *> *cacheProgressSubject;
@property (nonatomic, strong) RACDisposable *cacheProgressDisposable;
@property (nonatomic, strong) RACBehaviorSubject<NSNumber *> *hasPlaylistSubject;
@property (nonatomic, strong) NLResourceLoader *resourceLoader;
@property (nonatomic, strong) NLResourceLoader *nextResourceLoader;
@property (nonatomic, strong) AVPlayerItem *nextPlayerItem;
@property (nonatomic, assign) NSInteger preloadedNextIndex; // -1 表示未预加载

@property (nonatomic, strong) id timeObserver;  //周期性时间监听
@property (nonatomic, strong) AVPlayerItem *observedItem; // 当前被 KVO 的 item（强持有，避免快速切歌时 item 先释放导致 KVO 崩溃）
@property (nonatomic, strong) id endTimeObserver;       // 播放结束观察

@property (nonatomic, assign) NSUInteger playSwitchToken; // 丢弃过期异步回调（连续快速切歌）

@property (nonatomic, assign) float lastLoggedCacheProgress; // 用于缓存跟踪日志，仅变化时打印
@property (nonatomic, copy) NSString *lastLoggedCacheURL;    // 上一首打印时的 URL，切歌后重新打印
@end

@implementation NLPlayerManager

+ (instancetype)sharedManager {
    static NLPlayerManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[NLPlayerManager alloc] init];

    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        _volume = 0.8f;
        _playMode = NLPlayModeListLoop;
        _preloadedNextIndex = -1;
        _playbackStateSubject = [RACSubject subject];
        _songSubject = [RACSubject subject];
        _progressSubject = [RACSubject subject];
        _cacheProgressSubject = [RACSubject subject];
        _hasPlaylistSubject = [RACBehaviorSubject behaviorSubjectWithDefaultValue:@NO];

        _playbackStateSignal = _playbackStateSubject;
        _songSignal = _songSubject;
        _progressSignal = _progressSubject;
        _cacheProgressSignal = _cacheProgressSubject;
        _hasPlaylistSignal = _hasPlaylistSubject;
        [self setupAudioSession];
        [self setupRemoteCommands];
        [self updateNowPlayingInfo];
    }
    return self;
}

#pragma mark - 播放入口

- (void)playWithPlaylist:(NSArray<NLSong *> *)playlist startIndex:(NSInteger)index {
    NSLog(@"[PlayTrace] -> playWithPlaylist:startIndex: playlist.count=%lu index=%ld", (unsigned long)playlist.count, (long)index);
    if (!playlist || playlist.count == 0 || index < 0 || index >= playlist.count) {
        NSLog(@"[PlayTrace] playWithPlaylist: 参数不合法，直接返回");
        return;
    }
    NSLog(@"[PlayTrace] playWithPlaylist: 清理预加载并设置当前列表/索引");
    [self clearPreloadedItem];
    self.playlist = playlist;
    [self.hasPlaylistSubject sendNext:@YES];
    self.currentIndex = index;
    NLSong *song = playlist[index];
    if (!song.playURL) {
        NSLog(@"[PlayTrace] playWithPlaylist: 当前歌曲还没有 playURL，进入 Loading 状态");
        // 当前歌曲还没有播放 URL，显式将缓存进度归零，避免沿用上一首的缓存条
       // [self updateCacheProgressForURL:nil];
        [self setPlaybackState:NLPlaybackStateLoading];
        return;
    }
    // 更新当前歌曲并发送通知，先更新页面再播放音频，可以显得等待时间没有那么长/。
    self.currentSong = song;
    [NLSongRepository addPlayHistory:song];
    [self postSongChangedNotification];
    // 创建播放项并开始播放
    NSLog(@"[PlayTrace] playWithPlaylist: 即将调用 playWithURL:");
    [self playWithURL:song.playURL];
    [self updateNowPlayingInfo];
}

- (void)playWithURL:(NSURL *)url {
    NSLog(@"[PlayTrace] -> playWithURL: url=%@", url.absoluteString);
    [self removePeriodicTimeObserver];
    // 先更新缓存进度
    NSLog(@"[PlayTrace] playWithURL: 调用 updateCacheProgressForURL 读取缓存进度");
    [self updateCacheProgressForURL:url];

    self.lastLoggedCacheURL = nil;
    self.lastLoggedCacheProgress = -1.f;

    // 检查是否完整缓存
    if (self.latestCacheProgress >= 0.999f) {
        NSLog(@"[PlayTrace] playWithURL: latestCacheProgress>=0.999，尝试完整缓存播放");
        NSString *cachePath = [[NLCacheManager sharedManager] cacheFilePathForURL:url];
        if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
            NSLog(@"[PlayTrace] playWithURL: 找到完整缓存文件，走本地播放");
            [self playFullyCachedSongAtPath:cachePath];
            return;
        }
        NSLog(@"[PlayTrace] playWithURL: latestCacheProgress>=0.999 但本地文件不存在，回退为流式播放");
    }

    // 部分缓存，设置ResourceLoader
    NSLog(@"[PlayTrace] playWithURL: 准备创建 ResourceLoader 走流式播放");

    [self.cacheProgressDisposable dispose];
    self.cacheProgressDisposable = nil;

    [self.resourceLoader invalidateAndCancelAll];
    self.resourceLoader = nil;
    // 构造streaming URL
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    components.scheme = @"streaming";
    NSURL *customURL = components.URL;

    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:customURL options:nil];
    // 创建资源加载器
    self.resourceLoader = [[NLResourceLoader alloc] init];
    self.resourceLoader.originURL = url;
    [asset.resourceLoader setDelegate:self.resourceLoader queue:dispatch_get_main_queue()];

    //  订阅缓存进度 发送信号
    __weak typeof(self) weakSelf = self;
    NSUInteger subscribeToken = ++self.playSwitchToken;
    self.cacheProgressDisposable =
    [self.resourceLoader.cacheProgressSubject subscribeNext:^(NSNumber *progress) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf || subscribeToken != strongSelf.playSwitchToken) {
            return;
        }
        // 更新本地缓存进度
        strongSelf.latestCacheProgress = progress.floatValue;
        // 发送缓存进度信号
        [strongSelf.cacheProgressSubject sendNext:progress];
    }];

    NSLog(@"[PlayTrace] playWithURL: 创建 AVPlayerItem 并安装到 AVPlayer");

    // 创建AVPlayItem并开始播放
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    [self uninstallCurrentItemObserver];

    if (!self.player) {
        self.player = [[AVPlayer alloc] initWithPlayerItem:item];
    } else {
        [self.player replaceCurrentItemWithPlayerItem:item];
    }

    [self preloadNextItemIfNeeded];
    [self addPeriodicTimeObserver];
    [self observeCurrentItemForReady:item];
    [self observeCurrentItemForEnd:item];

    self.player.volume = self.volume;
    [self setPlaybackState:NLPlaybackStatePlaying];
    NSLog(@"[PlayTrace] playWithURL: 调用 setupAudioSession");
    [self setupAudioSession];
    NSLog(@"[PlayTrace] playWithURL: 调用 AVPlayer play 开始播放");
    [self.player play];
}

- (void)playFullyCachedSongAtPath:(NSString *)cachePath {
    NSLog(@"[Player] 播放完整缓存歌曲: %@", self.currentSong.title ?: @"(未知)");

    NSURL *localURL = [NSURL fileURLWithPath:cachePath];
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:localURL];

    [self uninstallCurrentItemObserver];

    if (!self.player) {
        self.player = [[AVPlayer alloc] initWithPlayerItem:item];
    } else {
        [self.player replaceCurrentItemWithPlayerItem:item];
    }

    [self preloadNextItemIfNeeded];
    [self addPeriodicTimeObserver];
    [self observeCurrentItemForReady:item];
    [self observeCurrentItemForEnd:item];

    self.player.volume = self.volume;
    [self setPlaybackState:NLPlaybackStatePlaying];
    NSLog(@"[PlayTrace] playFullyCachedSongAtPath: 调用 setupAudioSession");
    [self setupAudioSession];
    NSLog(@"[PlayTrace] playFullyCachedSongAtPath: 调用 AVPlayer play 开始播放");
    [self.player play];
}

- (void)preloadNextItemIfNeeded {
    NSLog(@"[PlayTrace] -> preloadNextItemIfNeeded");
    [self clearPreloadedItem];
    NSInteger nextIdx = [self indexForNextInMode:self.playMode];
    if (nextIdx < 0 || nextIdx >= (NSInteger)self.playlist.count) {
        NSLog(@"[PlayTrace] preloadNextItemIfNeeded: 没有下一首可预加载");
        return;
    }
    NLSong *nextSong = self.playlist[nextIdx];
    if (!nextSong.playURL) {
        NSLog(@"[PlayTrace] preloadNextItemIfNeeded: 下一首没有 playURL，跳过预加载");
        return;
    }

    NSURL *url = nextSong.playURL;
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    components.scheme = @"streaming";
    NSURL *customURL = components.URL;
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:customURL options:nil];
    NLResourceLoader *loader = [[NLResourceLoader alloc] init];
    loader.originURL = url;
    [asset.resourceLoader setDelegate:loader queue:dispatch_get_main_queue()];
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];

    self.nextResourceLoader = loader;
    self.nextPlayerItem = item;
    self.preloadedNextIndex = nextIdx;
}

#pragma mark - 播放控制

- (void)play {
    if (!self.player) return;
    [self.player play];
    [self setPlaybackState:NLPlaybackStatePlaying];
    [self updateNowPlayingInfo];
}

- (void)pause {
    if (!self.player) return;
    [self.player pause];
    [self setPlaybackState:NLPlaybackStatePaused];
    [self updateNowPlayingInfo];
}

- (void)togglePlayPause {
    if (self.playbackState == NLPlaybackStatePlaying) {
        [self pause];
    } else {
        [self play];
    }
}

//  pause为真正的暂停，stop为取消

- (void)stop {
    [self uninstallCurrentItemObserver];
    [self.player pause];
    if (self.timeObserver) {
        [self.player removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }
    [self clearPreloadedItem];
    self.resourceLoader = nil;
    self.player = nil;
    self.currentSong = nil;
    self.playlist = nil;
    [self.hasPlaylistSubject sendNext:@NO];
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = nil;
    self.currentIndex = 0;
    // 停止播放时显式清空缓存进度
    [self updateCacheProgressForURL:nil];
    [self setPlaybackState:NLPlaybackStateIdle];
}

#pragma mark - 播放列表调度
/// 根据播放模式计算下一首的索引
- (NSInteger)indexForNextInMode:(NLPlayMode)mode {
    if (!self.playlist || self.playlist.count == 0) return -1;
    switch (mode) {
        case NLPlayModeSingleLoop:
            return self.currentIndex; // 单曲循环：保持当前
        case NLPlayModeListLoop: {
            NSInteger next = self.currentIndex + 1;
            return next >= (NSInteger)self.playlist.count ? 0 : next;
        }
        case NLPlayModeRandom: {
            if (self.playlist.count <= 1) return self.currentIndex;
            NSInteger r;
            do {
                r = arc4random_uniform((uint32_t)self.playlist.count);
            } while (r == self.currentIndex);
            return r;
        }
    }
}

/// 根据播放模式计算上一首的索引
- (NSInteger)indexForPreviousInMode:(NLPlayMode)mode {
    if (!self.playlist || self.playlist.count == 0) return -1;
    switch (mode) {
        case NLPlayModeSingleLoop:
            return self.currentIndex; // 单曲循环：保持当前
        case NLPlayModeListLoop: {
            NSInteger prev = self.currentIndex - 1;
            return prev < 0 ? (NSInteger)self.playlist.count - 1 : prev;
        }
        case NLPlayModeRandom: {
            if (self.playlist.count <= 1) return self.currentIndex;
            NSInteger r;
            do {
                r = arc4random_uniform((uint32_t)self.playlist.count);
            } while (r == self.currentIndex);
            return r;
        }
    }
}

- (void)playNext {
    NSInteger idx = [self indexForNextInMode:self.playMode];
    if (idx < 0) return;
    [self playSongAtIndexIfNeeded:idx];
}

- (void)playPrevious {
    NSInteger idx = [self indexForPreviousInMode:self.playMode];
    if (idx < 0) return;
    [self playSongAtIndexIfNeeded:idx];
}

#pragma mark - 切歌调度核心

- (void)playSongAtIndexIfNeeded:(NSInteger)index {
    NSLog(@"[PlayTrace] -> playSongAtIndexIfNeeded: index=%ld", (long)index);
    self.playSwitchToken += 1;
    NSUInteger token = self.playSwitchToken;
    [self.progressSubject sendNext:@(0.0)];

    if (index < 0 || index >= (NSInteger)self.playlist.count) {
        NSLog(@"[PlayTrace] playSongAtIndexIfNeeded: index 越界，直接返回");
        return;
    }
    NLSong *song = self.playlist[index];
    if (index == self.preloadedNextIndex && self.nextPlayerItem && song.playURL) {
        NSLog(@"[PlayTrace] playSongAtIndexIfNeeded: 命中预加载，走 switchToPreloadedItemAndPlay");
        [self switchToPreloadedItemAndPlay:index];
        return;
    }
    NSLog(@"[PlayTrace] playSongAtIndexIfNeeded: 未命中预加载，清理预加载并判断是否已有 playURL");
    [self clearPreloadedItem];
    if (song.playURL) {
        NSLog(@"[PlayTrace] playSongAtIndexIfNeeded: 当前歌曲已有 playURL，直接 playSongAtIndex");
        [self playSongAtIndex:index];
    } else {
        NSLog(@"[PlayTrace] playSongAtIndexIfNeeded: 当前歌曲无 playURL，先去拉取播放 URL");
        // 新歌还在获取 URL 阶段，显式将缓存进度归零
        [self updateCacheProgressForURL:nil];
        [self setPlaybackState:NLPlaybackStateLoading];
        __weak typeof(self) weakSelf = self;
        [[NLSongService sharedService] fetchPlayableURLWithSongId:song.songId
                                                         success:^(NSURL *playURL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (!strongSelf) return;
                if (token != strongSelf.playSwitchToken) return; // 已切到其它歌，丢弃过期回调
                song.playURL = playURL;
                [strongSelf playSongAtIndex:index];
            });
        } failure:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"获取播放URL失败: %@", error.localizedDescription);
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (!strongSelf) return;
                if (token != strongSelf.playSwitchToken) return;
                [strongSelf setPlaybackState:NLPlaybackStateError];
            });
        }];
    }
}


- (void)switchToPreloadedItemAndPlay:(NSInteger)index {
    NSLog(@"[PlayTrace] -> switchToPreloadedItemAndPlay: index=%ld preloadedNextIndex=%ld hasNextItem=%@", (long)index, (long)self.preloadedNextIndex, self.nextPlayerItem ? @"YES" : @"NO");
    if (!self.nextPlayerItem || index != self.preloadedNextIndex) {
        NSLog(@"[PlayTrace] switchToPreloadedItemAndPlay: 条件不满足，直接返回");
        return;
    }
    BOOL wasPlaying = (self.playbackState == NLPlaybackStatePlaying);
    if (wasPlaying) {
        [self.player pause];  // 先暂停当前播放
    }

    [self removePeriodicTimeObserver];

    NLSong *song = self.playlist[index];
    self.currentIndex = index;
    self.currentSong = song;
    [NLSongRepository addPlayHistory:song];
    [self postSongChangedNotification];

    [self updateCacheProgressForURL:song.playURL];

    if (self.latestCacheProgress >= 0.999f) {
        NSString *cachePath = [[NLCacheManager sharedManager] cacheFilePathForURL:song.playURL];
        if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
            [self playFullyCachedSongAtPath:cachePath];
            return;
        }
    }

    [self.resourceLoader invalidateAndCancelAll];
    self.resourceLoader = self.nextResourceLoader;
    self.nextResourceLoader = nil;
    AVPlayerItem *item = self.nextPlayerItem;
    self.nextPlayerItem = nil;
    self.preloadedNextIndex = -1;

    [self uninstallCurrentItemObserver];
    [self.player replaceCurrentItemWithPlayerItem:item];

    __weak typeof(self) weakSelf = self;
    NSUInteger subscribeToken = ++self.playSwitchToken;

    [self.cacheProgressDisposable dispose];

    self.cacheProgressDisposable =
    [self.resourceLoader.cacheProgressSubject subscribeNext:^(NSNumber *progress) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf || subscribeToken != strongSelf.playSwitchToken) {
            return;
        }
        strongSelf.latestCacheProgress = progress.floatValue;
        [strongSelf.cacheProgressSubject sendNext:progress];
    }];

    [self observeCurrentItemForReady:item];
    [self observeCurrentItemForEnd:item];

    self.player.volume = self.volume;
    [self setPlaybackState:NLPlaybackStatePlaying];
  //  [self setupAudioSession];
    if (wasPlaying) {
        [self.player play];
    }

    [self preloadNextItemIfNeeded];
    [self addPeriodicTimeObserver];
}


- (void)clearPreloadedItem {
    NSLog(@"[PlayTrace] -> clearPreloadedItem");
    [self.nextResourceLoader invalidateAndCancelAll];
    self.nextResourceLoader = nil;
    self.nextPlayerItem = nil;
    self.preloadedNextIndex = -1;
}

- (void)playSongAtIndex:(NSInteger)index {
    if (index < 0 || index >= self.playlist.count) {
        return;
    }
    self.currentIndex = index;
    NLSong *song = self.playlist[index];
    self.currentSong = song;
    [NLSongRepository addPlayHistory:song];
    [self postSongChangedNotification];

    if (song.playURL) {
        [self playWithURL:song.playURL];
        return;
    }
    [self setPlaybackState:NLPlaybackStateLoading];
    __weak typeof(self) weakSelf = self;
    [[NLSongService sharedService] fetchPlayableURLWithSongId:song.songId
                                                     success:^(NSURL *playURL) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf || strongSelf.currentIndex != index) return;
            song.playURL = playURL;
            [strongSelf playWithURL:playURL];
        });
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            NSLog(@"获取播放URL失败: %@", error.localizedDescription);
            [strongSelf setPlaybackState:NLPlaybackStateError];
        });
    }];
}

#pragma mark - 进度和音量

// AVPlayer系统底层要求传入CMTime，其可以通过分数精确表示时间，而非double类型（会在大量运算后造成误差）
// CMTIME_IS_INDEFINITE (未决状态：常用于直播或未加载完)
// CMTIME_IS_NUMERIC验证他是数字吗？

- (float)currentProgress {
    AVPlayerItem *item = self.player.currentItem;
    if (!item) return 0.0f;
    CMTime duration = item.duration;
    if (!CMTIME_IS_NUMERIC(duration) || CMTIME_IS_INDEFINITE(duration) || CMTimeGetSeconds(duration) <= 0) {
        return 0.0f;
    }
    CMTime currentTime = self.player.currentTime;
    if (!CMTIME_IS_NUMERIC(currentTime)) {
        return 0.0f;
    }
    return CMTimeGetSeconds(currentTime) / CMTimeGetSeconds(duration);
}

- (NSTimeInterval)currentTime {
    if (!self.player.currentItem) {
        return 0.0;
    }
    CMTime time = self.player.currentTime;
    return CMTimeGetSeconds(time);
}

- (NSTimeInterval)totalTime {
    if (!self.player.currentItem) {
        return 0.0;
    }
    CMTime duration = self.player.currentItem.duration;
    if (CMTIME_IS_INVALID(duration)) {
        return 0.0;
    }
    return CMTimeGetSeconds(duration);
}

- (void)seekToProgress:(float)progress {
    AVPlayerItem *item = self.player.currentItem;
    if (!item) return;

    CMTime duration = item.duration;

    if (!CMTIME_IS_NUMERIC(duration) ||
        CMTIME_IS_INDEFINITE(duration) ||
        CMTimeGetSeconds(duration) <= 0) {
        return;
    }

    float clamped = fminf(fmaxf(progress, 0.f), 1.f);
    CMTime target = CMTimeMultiplyByFloat64(duration, clamped);

    [self.player seekToTime:target
            toleranceBefore:kCMTimeZero
             toleranceAfter:kCMTimeZero];
}

- (void)setVolume:(float)volume {
    _volume = volume;
    self.player.volume = volume;
}


//  播放进度和缓存进度
- (void)addPeriodicTimeObserver {
    if (self.timeObserver || !self.player) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    // 创建一个专属的并发队列来接收时间回调，绝对不用主线程避免堵死
    dispatch_queue_t timeQueue = dispatch_queue_create("com.nlspotify.timeobserver", DISPATCH_QUEUE_CONCURRENT);
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.5, NSEC_PER_SEC) queue:timeQueue usingBlock:^(CMTime time) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        float progress = [strongSelf currentProgress];
        // 既然接收在后台，那么 RAC 信号的发送也会在后台。
        // 这就要求你的外界（比如 ViewController）在收到信号更新 UI 时，必须切回主线程！
        [strongSelf.progressSubject sendNext:@(progress)];

        NSURL *url = strongSelf.currentSong.playURL;
        NSString *urlStr = url.absoluteString ?: @"";
        if (![urlStr isEqualToString:strongSelf.lastLoggedCacheURL]) {
            strongSelf.lastLoggedCacheURL = urlStr;
        }
    }];
}

- (void)updateCacheProgressForURL:(NSURL *)url {
    if (!url) {
        [self.cacheProgressSubject sendNext:@(0.f)];
        self.latestCacheProgress = 0.f;
        return;
    }
    float progress = [[NLCacheManager sharedManager] cacheProgressForURL:url];
    self.latestCacheProgress = progress;
    [self.cacheProgressSubject sendNext:@(progress)];

    // 日志
    NSString *urlStr = url.absoluteString ?: @"";
    if (![urlStr isEqualToString:self.lastLoggedCacheURL]) {
        self.lastLoggedCacheURL = urlStr;
        if (progress >= 0.999f) {
            NSLog(@"[缓存] 歌曲已完整缓存: %@", self.currentSong.title ?: @"(未知)");
        } else if (progress > 0) {
            NSLog(@"[缓存] 歌曲部分缓存: %.1f%%", progress * 100);
        } else {
            NSLog(@"[缓存] 歌曲无缓存");
        }
    }
}
#pragma mark - 监听

- (void)observeCurrentItemForReady:(AVPlayerItem *)item {
    if (!item) return;
    self.observedItem = item;
    [item addObserver:self forKeyPath:NSStringFromSelector(@selector(status)) options:NSKeyValueObservingOptionNew context:kPlayerCurrentItemStatusContext];
}

- (void)uninstallCurrentItemObserver {
    if (self.observedItem) {
        @try {
            [self.observedItem removeObserver:self forKeyPath:NSStringFromSelector(@selector(status)) context:kPlayerCurrentItemStatusContext];
        } @catch (NSException *exception) {}
        self.observedItem = nil;
    }
    if (self.endTimeObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.endTimeObserver];
        self.endTimeObserver = nil;
    }
}

// 当前歌曲什么时候完成
- (void)observeCurrentItemForEnd:(AVPlayerItem *)item {
    if (!item) return;
    if (self.endTimeObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.endTimeObserver];
        self.endTimeObserver = nil;
    }
    __weak typeof(self) weakSelf = self;
    self.endTimeObserver = [[NSNotificationCenter defaultCenter]
        addObserverForName:AVPlayerItemDidPlayToEndTimeNotification
                    object:item
                     queue:[NSOperationQueue mainQueue]
                usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        [strongSelf handleCurrentItemDidPlayToEnd];
    }];
}

//收到播放结束的通知后怎么做
- (void)handleCurrentItemDidPlayToEnd {
    switch (self.playMode) {
        case NLPlayModeSingleLoop:
            [self.player seekToTime:kCMTimeZero];
            [self.player play];
            break;
        case NLPlayModeListLoop:
        case NLPlayModeRandom:
            [self playNext];
            break;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context != kPlayerCurrentItemStatusContext) return;
    if (object != self.player.currentItem) return;
    
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(status))]) {
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        if (status == AVPlayerItemStatusReadyToPlay) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateNowPlayingInfo];
            });
        }
    }
}

#pragma mark - 通知发送

// 状态变化
- (void)setPlaybackState:(NLPlaybackState)state {
    _playbackState = state;
    // 发送 RAC 信号
    [self.playbackStateSubject sendNext:@(state)];
    [self updateNowPlayingInfo];
    //    [[NSNotificationCenter defaultCenter]
    //     postNotificationName:NLPlayerPlaybackStateDidChangeNotification
    //     object:self];
}

// 播放的歌曲变化
- (void)postSongChangedNotification {
    // 发送 RAC 信号
    if (self.currentSong) {
        [self.songSubject sendNext:self.currentSong];
    }
}

- (void)setPlayMode:(NLPlayMode)playMode {
    _playMode = playMode;
}


#pragma mark - 用于兼容灵动岛、锁屏播放等

- (void)setupAudioSession {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error = nil;

    [session setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (error) {
        NSLog(@"[Player] AudioSession Category Error: %@", error);
        error = nil;
    }
    [session setActive:YES error:&error];
    if (error) {
        NSLog(@"[Player] AudioSession Active Error: %@", error);
    }
}

- (void)setupRemoteCommands {
    MPRemoteCommandCenter *commandCenter =
        [MPRemoteCommandCenter sharedCommandCenter];

    __weak typeof(self) weakSelf = self;
    [commandCenter.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent *event) {
        [weakSelf play];
        return MPRemoteCommandHandlerStatusSuccess;
    }];

    // ⏸ Pause
    [commandCenter.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent *event) {
        [weakSelf pause];
        return MPRemoteCommandHandlerStatusSuccess;
    }];

    //Seek
    [commandCenter.changePlaybackPositionCommand
     addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent *event) {

        MPChangePlaybackPositionCommandEvent *e =
            (MPChangePlaybackPositionCommandEvent *)event;

        if (weakSelf.totalTime > 0) {
            float progress = e.positionTime / weakSelf.totalTime;
            [weakSelf seekToProgress:progress];
        }
        return MPRemoteCommandHandlerStatusSuccess;
    }];

    [commandCenter.nextTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent *event) {
        [weakSelf playNext];
        return MPRemoteCommandHandlerStatusSuccess;
    }];

    [commandCenter.previousTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent *event) {
        [weakSelf playPrevious];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
}

- (void)updateNowPlayingInfo {
    [self updateNowPlayingInfoWithArtwork:nil];
}

- (void)updateNowPlayingInfoWithArtwork:(UIImage *)artworkImage {
    if (!self.currentSong) return;

    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[MPMediaItemPropertyTitle]  = self.currentSong.title ?: @"";
    info[MPMediaItemPropertyArtist] = self.currentSong.artist ?: @"";

    // 封面：若调用方未传入则用缓存或占位图；若仍未命中缓存则异步加载后再刷一次
    UIImage *img = artworkImage;
    if (!img) {
        img = [UIImage imageNamed:@"placeholder_cover"];
        NSURL *coverURL = self.currentSong.coverURL;
        if (coverURL) {
            NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:coverURL];
            UIImage *cached = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key];
            if (cached) img = cached;
            else {
                __weak typeof(self) w = self;
                [[SDWebImageManager sharedManager] loadImageWithURL:coverURL
                                                             options:SDWebImageRetryFailed
                                                            progress:nil
                                                           completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                    if (!finished || !image || !imageURL) return;
                    NSURL *loadedURL = imageURL;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        __strong typeof(w) s = w;
                        if (!s || !s.currentSong.coverURL || ![s.currentSong.coverURL isEqual:loadedURL]) return;
                        [s updateNowPlayingInfoWithArtwork:image];
                    });
                }];
            }
        }
    }
    if (img) {
        MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithBoundsSize:img.size requestHandler:^UIImage * _Nonnull(CGSize size) {
            return img;
        }];
        info[MPMediaItemPropertyArtwork] = artwork;
    }
    // 进度与时长（等 AVPlayerItem 就绪后才有有效 duration，由 KVO 触发再次更新）
    if (self.player.currentItem) {
        CMTime duration = self.player.currentItem.duration;
        CMTime current  = self.player.currentTime;
        if (CMTIME_IS_NUMERIC(duration)) {
            info[MPMediaItemPropertyPlaybackDuration] = @(CMTimeGetSeconds(duration));
        }
        if (CMTIME_IS_NUMERIC(current)) {
            info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = @(CMTimeGetSeconds(current));
        }
    }

    info[MPNowPlayingInfoPropertyPlaybackRate] =
        (self.playbackState == NLPlaybackStatePlaying) ? @(1.0) : @(0.0);

    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = info;
}

- (void)removePeriodicTimeObserver {
    if (self.timeObserver && self.player) {
        @try {
            [self.player removeTimeObserver:self.timeObserver];
        } @catch (NSException *exception) {
            NSLog(@"[Player] 移除时间监听异常: %@", exception);
        } @finally {
            self.timeObserver = nil;
        }
    }
}
@end
