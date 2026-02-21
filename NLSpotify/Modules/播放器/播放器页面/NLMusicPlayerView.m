//
//  NLMusicPlayerView.m
//  NLSpotify
//
//  Created by 吴桐 on 2026/1/23.
//

#import "NLMusicPlayerView.h"
#import "NLExpandableTouchSlider.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>

static const CGFloat kCoverSize = 320.0;
static const CGFloat kControlBtnSize = 60.0;
static const CGFloat kSidePadding = 20.0;
static const CGFloat kBottomBtnSize = 26.0;      // 底部图标尺寸（细化）
static const CGFloat kBottomBtnSpacing = 56.0;  // 底部四按钮间距（拉大）
static const CGFloat kBottomBtnBottomInset = 48.0; // 距安全区底部

@interface NLMusicPlayerView ()

@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *artistLabel;
@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) UILabel *totalTimeLabel;
@property (nonatomic, strong) UIButton *playPauseButton;
@property (nonatomic, strong) UIButton *previousButton;
@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, strong) UISlider *progressSlider;
@property (nonatomic, strong) UISlider *volumeSlider;
@property (nonatomic, strong) UIImageView *volumeLeftIcon;
@property (nonatomic, strong) UIImageView *volumeRightIcon;

// 歌曲信息右侧按钮
@property (nonatomic, strong) UIButton *favoriteButton;
@property (nonatomic, strong) UIButton *moreButton;

// 底部四个按钮
@property (nonatomic, strong) UIButton *commentButton;
@property (nonatomic, strong) UIButton *playModeButton;
@property (nonatomic, strong) UIButton *playlistButton;
@property (nonatomic, strong) UIButton *addToPlaylistButton;

// 下滑横栏指示器
@property (nonatomic, strong) UIView *dismissIndicator;

@property (nonatomic, assign) NLPlayMode playMode;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL isTrackingProgress;
@property (nonatomic, assign) BOOL isTrackingVolume;

@end

@implementation NLMusicPlayerView

#pragma mark - Initializer

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // 使用稍微深一点的背景色，避免纯白
        if (@available(iOS 13.0, *)) {
            self.backgroundColor = [UIColor secondarySystemBackgroundColor];
        } else {
            self.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
        }
        self.playMode = NLPlayModeListLoop;
        self.isPlaying = NO;
        [self setupUI];
        [self setupConstraints];
    }
    return self;
}

#pragma mark - UI Setup

- (void)setupUI {
    // 1. 封面图片（先添加，在底层）
    self.coverImageView = [[UIImageView alloc] init];
    self.coverImageView.layer.cornerRadius = 12; // 更小的圆角
    self.coverImageView.clipsToBounds = YES;
    self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.coverImageView.backgroundColor = [UIColor tertiarySystemFillColor];
    [self addSubview:self.coverImageView];
    
    // 2. 下滑横栏指示器（在封面上方，类似iPhone底部上滑退出指示条）
    self.dismissIndicator = [[UIView alloc] init];
    self.dismissIndicator.backgroundColor = [UIColor tertiaryLabelColor];
    self.dismissIndicator.layer.cornerRadius = 2.5; // 圆角
    [self addSubview:self.dismissIndicator];

    // 3. 歌曲信息（左对齐）
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textColor = [UIColor labelColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.text = @"歌曲标题";
    [self addSubview:self.titleLabel];

    self.artistLabel = [[UILabel alloc] init];
    self.artistLabel.textColor = [UIColor secondaryLabelColor];
    self.artistLabel.font = [UIFont systemFontOfSize:16];
    self.artistLabel.textAlignment = NSTextAlignmentLeft;
    self.artistLabel.text = @"歌手";
    [self addSubview:self.artistLabel];
    
    // 4. 收藏和更多按钮（在歌曲信息右侧）
    self.favoriteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.favoriteButton setImage:[UIImage systemImageNamed:@"star"] forState:UIControlStateNormal];
    self.favoriteButton.tintColor = [UIColor labelColor];
    [self.favoriteButton addTarget:self action:@selector(favoriteTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.favoriteButton];
    
    self.moreButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.moreButton setImage:[UIImage systemImageNamed:@"ellipsis"] forState:UIControlStateNormal];
    self.moreButton.tintColor = [UIColor labelColor];
    [self.moreButton addTarget:self action:@selector(moreTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.moreButton];

    // 5. 时间标签和进度条
    self.currentTimeLabel = [[UILabel alloc] init];
    self.currentTimeLabel.textColor = [UIColor secondaryLabelColor];
    self.currentTimeLabel.font = [UIFont systemFontOfSize:14];
    self.currentTimeLabel.textAlignment = NSTextAlignmentLeft;
    self.currentTimeLabel.text = @"0:00";
    [self addSubview:self.currentTimeLabel];

    self.totalTimeLabel = [[UILabel alloc] init];
    self.totalTimeLabel.textColor = [UIColor secondaryLabelColor];
    self.totalTimeLabel.font = [UIFont systemFontOfSize:14];
    self.totalTimeLabel.textAlignment = NSTextAlignmentRight;
    self.totalTimeLabel.text = @"0:00";
    [self addSubview:self.totalTimeLabel];

    // 进度条
    self.progressSlider = [[NLExpandableTouchSlider alloc] init];
    [self.progressSlider setThumbImage:[UIImage new] forState:UIControlStateNormal];
    self.progressSlider.minimumTrackTintColor = [UIColor labelColor];
    self.progressSlider.maximumTrackTintColor = [UIColor tertiarySystemFillColor];
    // 添加多个触摸事件，确保能够响应滑动
    [self.progressSlider addTarget:self action:@selector(progressChanged:) forControlEvents:UIControlEventValueChanged];
    [self.progressSlider addTarget:self action:@selector(progressTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self.progressSlider addTarget:self action:@selector(progressTouchUp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    [self addSubview:self.progressSlider];

    // 6. 播放控制按钮（居中，使用双箭头图标）
    // 上一首按钮（双左箭头）
    self.previousButton = [UIButton buttonWithType:UIButtonTypeSystem];
    UIImageSymbolConfiguration *prevConfig = [UIImageSymbolConfiguration configurationWithPointSize:28];
    [self.previousButton setImage:[UIImage systemImageNamed:@"backward.end.fill" withConfiguration:prevConfig] forState:UIControlStateNormal];
    self.previousButton.tintColor = [UIColor labelColor];
    [self.previousButton addTarget:self action:@selector(previousTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.previousButton];

    // 播放/暂停按钮（大按钮）
    self.playPauseButton = [UIButton buttonWithType:UIButtonTypeSystem];
    UIImageSymbolConfiguration *playConfig = [UIImageSymbolConfiguration configurationWithPointSize:36];
    [self.playPauseButton setImage:[UIImage systemImageNamed:@"play.fill" withConfiguration:playConfig] forState:UIControlStateNormal];
    self.playPauseButton.tintColor = [UIColor labelColor];
    [self.playPauseButton addTarget:self action:@selector(playPauseTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.playPauseButton];

    // 下一首按钮（双右箭头）
    self.nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.nextButton setImage:[UIImage systemImageNamed:@"forward.end.fill" withConfiguration:prevConfig] forState:UIControlStateNormal];
    self.nextButton.tintColor = [UIColor labelColor];
    [self.nextButton addTarget:self action:@selector(nextTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.nextButton];

    // 7. 音量控制（左侧speaker图标，右侧speaker.wave图标）
    self.volumeLeftIcon = [[UIImageView alloc] init];
    self.volumeLeftIcon.image = [UIImage systemImageNamed:@"speaker.fill"];
    self.volumeLeftIcon.tintColor = [UIColor secondaryLabelColor];
    self.volumeLeftIcon.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.volumeLeftIcon];
    
    self.volumeRightIcon = [[UIImageView alloc] init];
    self.volumeRightIcon.image = [UIImage systemImageNamed:@"speaker.wave.3.fill"];
    self.volumeRightIcon.tintColor = [UIColor secondaryLabelColor];
    self.volumeRightIcon.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.volumeRightIcon];

    self.volumeSlider = [[NLExpandableTouchSlider alloc] init];
    self.volumeSlider.value = 0.7;
    [self.volumeSlider setThumbImage:[UIImage new] forState:UIControlStateNormal];
    self.volumeSlider.minimumTrackTintColor = [UIColor secondaryLabelColor];
    self.volumeSlider.maximumTrackTintColor = [UIColor tertiarySystemFillColor];
    // 添加多个触摸事件，确保能够响应滑动
    [self.volumeSlider addTarget:self action:@selector(volumeChanged:) forControlEvents:UIControlEventValueChanged];
    [self.volumeSlider addTarget:self action:@selector(volumeTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self.volumeSlider addTarget:self action:@selector(volumeTouchUp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    [self addSubview:self.volumeSlider];

    self.commentButton = [self createBottomButtonWithIcon:@"message" action:@selector(commentTapped)];
    self.playModeButton = [self createBottomButtonWithIcon:@"repeat" action:@selector(playModeTapped)];
    self.playlistButton = [self createBottomButtonWithIcon:@"list.bullet" action:@selector(playlistTapped)];
    self.addToPlaylistButton = [self createBottomButtonWithIcon:@"plus.circle" action:@selector(addToPlaylistTapped)];

    [self addSubview:self.commentButton];
    [self addSubview:self.playModeButton];
    [self addSubview:self.playlistButton];
    [self addSubview:self.addToPlaylistButton];
}

- (UIButton *)createBottomButtonWithIcon:(NSString *)iconName action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:kBottomBtnSize weight:UIImageSymbolWeightLight];
    [button setImage:[UIImage systemImageNamed:iconName withConfiguration:config] forState:UIControlStateNormal];
    button.tintColor = [UIColor labelColor];
    button.adjustsImageWhenHighlighted = NO;
    [button addTarget:self action:@selector(bottomButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(bottomButtonTouchUp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)bottomButtonTouchDown:(UIButton *)button {
    [UIView animateWithDuration:0.1 animations:^{
        button.transform = CGAffineTransformMakeScale(0.9, 0.9);
        button.alpha = 0.7;
    }];
}

- (void)bottomButtonTouchUp:(UIButton *)button {
    [UIView animateWithDuration:0.2
                          delay:0
         usingSpringWithDamping:0.6
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        button.transform = CGAffineTransformIdentity;
        button.alpha = 1.0;
    } completion:nil];
}

- (void)setupConstraints {
    // 1. 封面（距离顶部）
    [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_safeAreaLayoutGuideTop).offset(60);
        make.centerX.equalTo(self);
        make.width.height.mas_equalTo(kCoverSize);
    }];
    
    // 2. 下滑横栏指示器（在封面上方，类似iPhone底部上滑退出指示条）
    [self.dismissIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.coverImageView.mas_top).offset(-42); // 在封面上方12pt
        make.centerX.equalTo(self);
        make.width.mas_equalTo(80); // 类似iPhone底部指示条的大小
        make.height.mas_equalTo(5); // 高度
    }];

    // 3. 歌曲信息（左对齐，右侧有按钮）
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.coverImageView.mas_bottom).offset(24);
        make.left.equalTo(self).offset(kSidePadding);
        make.right.lessThanOrEqualTo(self.favoriteButton.mas_left).offset(-16);
    }];

    [self.artistLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(4);
        make.left.equalTo(self.titleLabel);
        make.right.lessThanOrEqualTo(self.favoriteButton.mas_left).offset(-16);
    }];
    
    // 收藏和更多按钮（在标题右侧，水平对齐）
    [self.favoriteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.titleLabel);
        make.right.equalTo(self.moreButton.mas_left).offset(-20);
        make.size.mas_equalTo(32);
    }];
    
    [self.moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.titleLabel);
        make.right.equalTo(self).offset(-kSidePadding);
        make.size.mas_equalTo(32);
    }];

    // 4. 进度条和时间标签（进度条在上，时间标签在下，进度条延长）
    [self.progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.artistLabel.mas_bottom).offset(24);
        make.left.equalTo(self).offset(30);
        make.right.equalTo(self).offset(-30);
        make.height.mas_equalTo(6); // 视觉上保持细线
    }];
    
    [self.currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.progressSlider.mas_bottom).offset(11);
        make.left.equalTo(self.progressSlider);
        make.width.mas_equalTo(50);
    }];

    [self.totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.currentTimeLabel);
        make.right.equalTo(self.progressSlider);
        make.width.mas_equalTo(50);
    }];

    // 5. 播放控制按钮（居中，均匀分布）
    [self.playPauseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.currentTimeLabel.mas_bottom).offset(32);
        make.centerX.equalTo(self);
        make.size.mas_equalTo(kControlBtnSize);
    }];

    [self.previousButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.playPauseButton);
        make.right.equalTo(self.playPauseButton.mas_left).offset(-40);
        make.size.mas_equalTo(44);
    }];

    [self.nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.playPauseButton);
        make.left.equalTo(self.playPauseButton.mas_right).offset(40);
        make.size.mas_equalTo(44);
    }];

    // 6. 音量控制（缩短音量条，图标更靠近）
    [self.volumeLeftIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.playPauseButton.mas_bottom).offset(32);
        make.left.equalTo(self).offset(40);
        make.width.height.mas_equalTo(18);
    }];
    
    [self.volumeRightIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.volumeLeftIcon);
        make.right.equalTo(self).offset(-40);
        make.width.height.mas_equalTo(18);
    }];

    [self.volumeSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.volumeLeftIcon);
        make.left.equalTo(self.volumeLeftIcon.mas_right).offset(15);
        make.right.equalTo(self.volumeRightIcon.mas_left).offset(-15);
        make.height.mas_equalTo(5); // 视觉上保持细线
    }];

    // 7. 底部四个功能按钮（间距拉大、图标细化、居中分布）
    NSArray *bottomButtons = @[self.commentButton, self.playModeButton, self.playlistButton, self.addToPlaylistButton];
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat btnSize = 44.0; // 点击区域保持 44pt，图标为 kBottomBtnSize 更细
    CGFloat spacing = kBottomBtnSpacing;
    CGFloat totalWidth = bottomButtons.count * btnSize + (bottomButtons.count - 1) * spacing;
    CGFloat startX = (screenWidth - totalWidth) / 2.0;

    for (NSInteger i = 0; i < bottomButtons.count; i++) {
        UIButton *button = bottomButtons[i];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-kBottomBtnBottomInset);
            make.left.equalTo(self).offset(startX + i * (btnSize + spacing));
            make.size.mas_equalTo(btnSize);
        }];
    }
}


- (void)updateTitle:(NSString *)title artist:(NSString *)artist {
    self.titleLabel.text = title ?: @"";
    self.artistLabel.text = artist ?: @"";
}

- (void)updateCoverURL:(NSURL *)url {
    if (url) {
        [self.coverImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder"]];
    } else {
        self.coverImageView.image = [UIImage imageNamed:@"placeholder"];
    }
}

- (void)updatePlayState:(BOOL)isPlaying {
    self.isPlaying = isPlaying;

    // 更新播放按钮图标
    NSString *iconName = isPlaying ? @"pause.fill" : @"play.fill";
    UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:36];
    [self.playPauseButton setImage:[UIImage systemImageNamed:iconName withConfiguration:config] forState:UIControlStateNormal];

    // 封面放大缩小动画（增大变化幅度，减小播放时的大小）
    // 播放时：0.92（更小，变化幅度更大），暂停时：1.0
    CGFloat baseScale = isPlaying ? 0.92 : 1.0; // 减小播放时的封面大小，增大变化幅度
    CGFloat dismissScale = 1.0 - self.dismissProgress * 0.1;
    [UIView animateWithDuration:0.4
                          delay:0
         usingSpringWithDamping:0.6
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
        self.coverImageView.transform = CGAffineTransformMakeScale(baseScale * dismissScale, baseScale * dismissScale);
    } completion:nil];
}

- (void)updateProgress:(float)progress {
    if (!self.progressSlider.isTracking) {
        self.progressSlider.value = progress;
    }
}

- (void)updateCurrentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
    self.currentTimeLabel.text = [self formattedTime:currentTime];
    // 显示剩余时间（负数格式）
    NSTimeInterval remainingTime = totalTime - currentTime;
    if (remainingTime > 0) {
        self.totalTimeLabel.text = [NSString stringWithFormat:@"%@", [self formattedTime:remainingTime]];
    } else {
        self.totalTimeLabel.text = @"0:00";
    }
}

- (void)updateVolume:(float)volume {
    self.volumeSlider.value = volume;
}

- (void)setDismissProgress:(CGFloat)dismissProgress {
    _dismissProgress = dismissProgress;

    // 更新封面缩放（下滑时缩小，考虑播放状态）
    CGFloat baseScale = self.isPlaying ? 0.92 : 1.0; // 减小播放时的封面大小，增大变化幅度
    CGFloat dismissScale = 1.0 - dismissProgress * 0.1;
    self.coverImageView.transform = CGAffineTransformMakeScale(baseScale * dismissScale, baseScale * dismissScale);
    
    // 更新整体视图的透明度（轻微变暗）
    self.alpha = 1.0 - dismissProgress * 0.2;
}

- (void)updatePlayMode:(NLPlayMode)playMode {
    self.playMode = playMode;

    NSString *iconName = @"";
    switch (playMode) {
        case NLPlayModeListLoop:
            iconName = @"repeat";
            break;
        case NLPlayModeSingleLoop:
            iconName = @"repeat.1";
            break;
        case NLPlayModeRandom:
            iconName = @"shuffle";
            break;
    }

    UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:24];
    [self.playModeButton setImage:[UIImage systemImageNamed:iconName withConfiguration:config] forState:UIControlStateNormal];
}

#pragma mark - Helper Methods

- (NSString *)formattedTime:(float)seconds {
    int totalSeconds = (int)seconds;
    int minutes = totalSeconds / 60;
    int remainingSeconds = totalSeconds % 60;
    return [NSString stringWithFormat:@"%d:%02d", minutes, remainingSeconds];
}

// 创建指定高度和颜色的 track 图片（用于视觉控制）
- (UIImage *)trackImageWithHeight:(CGFloat)height color:(UIColor *)color {
    // 创建一个可拉伸的 track 图片
    // 使用 3xheight 的图片，中间 1xheight 区域可拉伸
    CGSize size = CGSizeMake(3, height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 填充颜色
    [color setFill];
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // 设置可拉伸区域（中间 1xheight 区域可拉伸，左右各1pt固定）
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 1, 0, 1);
    return [image resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
}

#pragma mark - Actions

- (void)favoriteTapped {
    // 切换收藏状态
    // TODO: 实现收藏功能
}

- (void)moreTapped {
    // 显示更多选项
    // TODO: 实现更多功能
}

- (void)playPauseTapped {
    [self.delegate musicPlayerViewDidTapPlayPause:self];
}

- (void)previousTapped {
    [self.delegate musicPlayerViewDidTapPrevious:self];
}

- (void)nextTapped {
    [self.delegate musicPlayerViewDidTapNext:self];
}

- (void)commentTapped {
    if ([self.delegate respondsToSelector:@selector(musicPlayerViewDidTapComment:)]) {
        [self.delegate musicPlayerViewDidTapComment:self];
    }
}

- (void)playlistTapped {
    if ([self.delegate respondsToSelector:@selector(musicPlayerViewDidTapPlaylist:)]) {
        [self.delegate musicPlayerViewDidTapPlaylist:self];
    }
}

- (void)addToPlaylistTapped {
//    if ([self.delegate respondsToSelector:@selector(musicPlayerViewDidTapAddToPlaylist:)]) {
//        [self.delegate musicPlayerViewDidTapAddToPlaylist:self];
//    }
}

- (void)playModeTapped {
    // 循环切换播放模式
    NLPlayMode nextMode = (self.playMode + 1) % 3;
    [self updatePlayMode:nextMode];

    if ([self.delegate respondsToSelector:@selector(musicPlayerView:didChangePlayMode:)]) {
        [self.delegate musicPlayerView:self didChangePlayMode:nextMode];
    }
}

- (void)progressChanged:(UISlider *)slider {
    if ([self.delegate respondsToSelector:@selector(musicPlayerView:didChangeProgress:)]) {
        [self.delegate musicPlayerView:self didChangeProgress:slider.value];
    }
}

- (void)volumeChanged:(UISlider *)slider {
    if ([self.delegate respondsToSelector:@selector(musicPlayerView:didChangeVolume:)]) {
        [self.delegate musicPlayerView:self didChangeVolume:slider.value];
    }
}

- (void)progressTouchDown:(UISlider *)slider {
    // 开始拖动进度条
    self.isTrackingProgress = YES;
    
    // Apple Music 同款效果：拖动时加粗
    [self.progressSlider mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(10); // 从2pt加粗到4pt
    }];
    [UIView animateWithDuration:0.2
                          delay:0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        [self layoutIfNeeded];
    } completion:nil];
}

- (void)progressTouchUp:(UISlider *)slider {
    // 结束拖动进度条
    self.isTrackingProgress = NO;
    
    // 恢复细线
    [self.progressSlider mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(2); // 恢复为2pt
    }];
    [UIView animateWithDuration:0.2
                          delay:0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        [self layoutIfNeeded];
    } completion:nil];
    
    // 确保最终值被应用
    if ([self.delegate respondsToSelector:@selector(musicPlayerView:didChangeProgress:)]) {
        [self.delegate musicPlayerView:self didChangeProgress:slider.value];
    }
}

- (void)volumeTouchDown:(UISlider *)slider {
    // 开始拖动音量条
    self.isTrackingVolume = YES;
    
    // Apple Music 同款效果：拖动时加粗
    [self.volumeSlider mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(4); // 从2pt加粗到4pt
    }];
    [UIView animateWithDuration:0.2
                          delay:0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        [self layoutIfNeeded];
    } completion:nil];
}

- (void)volumeTouchUp:(UISlider *)slider {
    // 结束拖动音量条
    self.isTrackingVolume = NO;
    
    // 恢复细线
    [self.volumeSlider mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(2); // 恢复为2pt
    }];
    [UIView animateWithDuration:0.2
                          delay:0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        [self layoutIfNeeded];
    } completion:nil];
}

@end
