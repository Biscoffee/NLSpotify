//
//  NLPlayerManager.h
//  NLSpotify
//
//  Created by 吴桐 on 2026/1/18.
//

#import <Foundation/Foundation.h>
#import "ReactiveObjC/ReactiveObjC.h"
#import <MediaPlayer/MediaPlayer.h>
#import "NLSong.h"

typedef NS_ENUM(NSUInteger, NLPlaybackState) {
    NLPlaybackStateIdle,
    NLPlaybackStateLoading,
    NLPlaybackStatePlaying,
    NLPlaybackStatePaused,
    NLPlaybackStateEnded,
    NLPlaybackStateError
};

NS_ASSUME_NONNULL_BEGIN

@interface NLPlayerManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, strong, readonly) NLSong *currentSong;
@property (nonatomic, assign, readonly) NLPlaybackState playbackState;
@property (nonatomic, strong, readonly) NSArray<NLSong *> *playlist;
@property (nonatomic, assign) float volume;
@property (nonatomic, assign, readonly) float currentProgress;
@property (nonatomic, assign, readonly) NSTimeInterval currentTime;
@property (nonatomic, assign, readonly) NSTimeInterval totalTime;
@property (nonatomic, assign, readonly) NSInteger currentIndex;


// 播放状态（Playing / Paused / Loading）
@property (nonatomic, strong, readonly) RACSignal<NSNumber *> *playbackStateSignal;

// 当前歌曲变化
@property (nonatomic, strong, readonly) RACSignal<NLSong *> *songSignal;

// 播放进度
@property (nonatomic, strong, readonly) RACSignal<NSNumber *> *progressSignal;



//- (void)playWithSong:(NLSong *)song;
- (void)playWithPlaylist:(NSArray<NLSong *> *)playlist startIndex:(NSInteger)index;
- (void)play;
- (void)pause;
- (void)togglePlayPause;
- (void)stop;
- (void)playNext;
- (void)playPrevious;
- (void)seekToProgress:(float)progress;

// Audio Session
- (void)setupAudioSession;

// Remote Control
- (void)setupRemoteCommands;

// Lock Screen / Control Center
- (void)updateNowPlayingInfo;

@end

NS_ASSUME_NONNULL_END
