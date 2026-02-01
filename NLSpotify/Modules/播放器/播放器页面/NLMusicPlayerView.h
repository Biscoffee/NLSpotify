//
//  NLMusicPlayerView.h
//  NLSpotify
//
//  Created by 吴桐 on 2026/1/23.
//

#import <UIKit/UIKit.h>


@class NLMusicPlayerView;

typedef NS_ENUM(NSInteger, NLPlayMode) {
    NLPlayModeListLoop,    // 列表循环
    NLPlayModeSingleLoop,  // 单曲循环
    NLPlayModeRandom       // 随机播放
};

NS_ASSUME_NONNULL_BEGIN

@class NLMusicPlayerView;

@protocol NLMusicPlayerViewDelegate <NSObject>

@optional
- (void)musicPlayerViewDidTapClose:(NLMusicPlayerView *)view;
- (void)musicPlayerViewDidTapPlayPause:(NLMusicPlayerView *)view;
- (void)musicPlayerViewDidTapPrevious:(NLMusicPlayerView *)view;
- (void)musicPlayerViewDidTapNext:(NLMusicPlayerView *)view;
- (void)musicPlayerView:(NLMusicPlayerView *)view didChangeProgress:(float)progress;
- (void)musicPlayerView:(NLMusicPlayerView *)view didChangeVolume:(float)volume;
- (void)musicPlayerViewDidTapComment:(NLMusicPlayerView *)view;
- (void)musicPlayerView:(NLMusicPlayerView *)view didChangePlayMode:(NLPlayMode)playMode;
- (void)musicPlayerViewDidTapPlaylist:(NLMusicPlayerView *)view;

@end

@interface NLMusicPlayerView : UIView

@property (nonatomic, weak) id<NLMusicPlayerViewDelegate> delegate;
@property (nonatomic, readonly) BOOL isTrackingProgress;
@property (nonatomic, assign) CGFloat coverScaleProgress;
@property (nonatomic, assign) CGFloat dismissProgress; // 下滑进度 0.0-1.0

// 暴露 slider 用于手势识别器
@property (nonatomic, strong, readonly) UISlider *progressSlider;
@property (nonatomic, strong, readonly) UISlider *volumeSlider;

- (void)updateTitle:(NSString *)title artist:(NSString *)artist;
- (void)updateCoverURL:(NSURL *)url;
- (void)updateProgress:(float)progress;
- (void)updateCurrentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime;
- (void)updateVolume:(float)volume;
- (void)updatePlayState:(BOOL)isPlaying;

@end

NS_ASSUME_NONNULL_END
