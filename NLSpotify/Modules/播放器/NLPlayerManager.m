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
@property (nonatomic, strong) RACSubject<NSNumber *> *playbackStateSubject;
@property (nonatomic, strong) RACSubject<NLSong *> *songSubject;
@property (nonatomic, strong) RACSubject<NSNumber *> *progressSubject;

@property (nonatomic, strong) id timeObserver;
@property (nonatomic, weak) AVPlayerItem *observedItem; // 当前被 KVO 的 item，用于移除观察
@property (nonatomic, strong) id endTimeObserver;       // 播放结束观察
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
        _playbackStateSubject = [RACSubject subject];
        _songSubject = [RACSubject subject];
        _progressSubject = [RACSubject subject];

        _playbackStateSignal = _playbackStateSubject;
        _songSignal = _songSubject;
        _progressSignal = _progressSubject;
        [self setupAudioSession];
        [self setupRemoteCommands];
        [self updateNowPlayingInfo];
    }
    return self;
}

#pragma mark - 播放控制

//- (void)playWithSong:(NLSong *)song {
//    if (!song || !song.playURL) return;
//
//
//    if (self.currentSong == song && self.player) {
//        [self play];
//        return;
//    }
//    self.currentSong = song;
//    self.playlist = @[song];
//    self.currentIndex = 0;
//    [self postSongChangedNotification];
//
//    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:song.playURL];
//
//    if (!self.player) {
//        self.player = [[AVPlayer alloc] initWithPlayerItem:item];
//        [self addPeriodicTimeObserver];
//    } else {
//        [self.player replaceCurrentItemWithPlayerItem:item];
//    }
//    self.player.volume = self.volume;
//
//    [self setPlaybackState:NLPlaybackStatePlaying];
//    [self.player play];
//}

- (void)playWithPlaylist:(NSArray<NLSong *> *)playlist startIndex:(NSInteger)index {
    if (!playlist || playlist.count == 0 || index < 0 || index >= playlist.count) {
        return;
    }
    self.playlist = playlist;
    self.currentIndex = index;
    NLSong *song = playlist[index];
    if (!song.playURL) {
        [self setPlaybackState:NLPlaybackStateLoading];
        return;
    }
    // 更新当前歌曲并发送通知，先更新页面再播放音频，可以显得等待时间没有那么长/。
    self.currentSong = song;
    [NLSongRepository addPlayHistory:song];
    [self postSongChangedNotification];
    // 创建播放项并开始播放
    [self playWithURL:song.playURL];
    [self updateNowPlayingInfo];
}

- (void)playWithURL:(NSURL *)url {
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
    
    [self uninstallCurrentItemObserver];
    
    if (!self.player) {
        self.player = [[AVPlayer alloc] initWithPlayerItem:item];
        [self addPeriodicTimeObserver];
    } else {
        [self.player replaceCurrentItemWithPlayerItem:item];
        if (!self.timeObserver) {
            [self addPeriodicTimeObserver];
        }
    }
    
    [self observeCurrentItemForReady:item];
    [self observeCurrentItemForEnd:item];
    self.player.volume = self.volume;
    [self setPlaybackState:NLPlaybackStatePlaying];
    [self.player play];
    
    // 先更新一次（标题、艺人、占位图等），时长和封面在 item ready / 图加载完后再更新
    [self updateNowPlayingInfo];
}


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
    self.player = nil;
    self.currentSong = nil;
    self.playlist = nil;
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = nil;
    self.currentIndex = 0;
    [self setPlaybackState:NLPlaybackStateIdle];
}

- (void)setPlayMode:(NLPlayMode)playMode {
    _playMode = playMode;
}

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

- (void)playSongAtIndexIfNeeded:(NSInteger)index {
    if (index < 0 || index >= (NSInteger)self.playlist.count) return;
    NLSong *song = self.playlist[index];
    if (song.playURL) {
        [self playSongAtIndex:index];
    } else {
        [self setPlaybackState:NLPlaybackStateLoading];
        __weak typeof(self) weakSelf = self;
        [[NLSongService sharedService] fetchPlayableURLWithSongId:song.songId
                                                         success:^(NSURL *playURL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                song.playURL = playURL;
                [weakSelf playSongAtIndex:index];
            });
        } failure:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"获取播放URL失败: %@", error.localizedDescription);
                [weakSelf setPlaybackState:NLPlaybackStateError];
            });
        }];
    }
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

//AVPlayer系统底层要求传入CMTime，其可以通过分数精确表示时间，而非double类型（会在大量运算后造成误差）

- (float)currentProgress {
    if (!self.player.currentItem) {
        return 0.0f;
    }
    CMTime currentTime = self.player.currentTime;
    CMTime duration = self.player.currentItem.duration;
    if (CMTIME_IS_INVALID(duration) || CMTimeGetSeconds(duration) == 0) {
        return 0.0f;
    }
    return (float)(CMTimeGetSeconds(currentTime) / CMTimeGetSeconds(duration));
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
    if (!self.player.currentItem) {
        return;
    }
    CMTime duration = self.player.currentItem.duration;
    if (CMTIME_IS_INVALID(duration)) {
        return;
    }
    float clampedProgress = fminf(fmaxf(progress, 0.0f), 1.0f);
    CMTime targetTime = CMTimeMultiplyByFloat64(duration, clampedProgress);
    [self.player seekToTime:targetTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (void)setVolume:(float)volume {
    _volume = volume;
    self.player.volume = volume;
}

- (void)addPeriodicTimeObserver {
    if (self.timeObserver || !self.player) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.5, NSEC_PER_SEC)
                                                                  queue:dispatch_get_main_queue()
                                                             usingBlock:^(CMTime time) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        float progress = [strongSelf currentProgress];
        [strongSelf.progressSubject sendNext:@(progress)];
    }];
}

#pragma mark - 当前 AVPlayerItem 就绪时再更新锁屏信息

- (void)observeCurrentItemForReady:(AVPlayerItem *)item {
    if (!item) return;
    self.observedItem = item;
    [item addObserver:self
          forKeyPath:NSStringFromSelector(@selector(status))
             options:NSKeyValueObservingOptionNew
             context:kPlayerCurrentItemStatusContext];
}

- (void)uninstallCurrentItemObserver {
    if (self.observedItem) {
        @try {
            [self.observedItem removeObserver:self
                                  forKeyPath:NSStringFromSelector(@selector(status))
                                     context:kPlayerCurrentItemStatusContext];
        } @catch (NSException *exception) {}
        self.observedItem = nil;
    }
    if (self.endTimeObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.endTimeObserver];
        self.endTimeObserver = nil;
    }
}

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

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
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

    // 保留 Notification 代码（已注释）
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
    
    // 保留 Notification 代码（已注释）
    //    [[NSNotificationCenter defaultCenter]
    //     postNotificationName:NLPlayerSongDidChangeNotification
    //     object:self];
}

- (void)setupAudioSession {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error = nil;

    [session setCategory:AVAudioSessionCategoryPlayback
                   mode:AVAudioSessionModeDefault
                options:AVAudioSessionCategoryOptionAllowAirPlay
                  error:&error];

    if (error) {
        NSLog(@"[Player] AudioSession Category Error: %@", error);
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

    // ▶️ Play
    [commandCenter.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent *event) {
        [weakSelf play];
        return MPRemoteCommandHandlerStatusSuccess;
    }];

    // ⏸ Pause
    [commandCenter.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent *event) {
        [weakSelf pause];
        return MPRemoteCommandHandlerStatusSuccess;
    }];

    // ⏩ Seek
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

@end
