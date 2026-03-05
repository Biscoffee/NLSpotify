//
//  NLSongListHeaderView.h
//  NLSpotify
//
//  Created by 吴桐 on 2026/1/8.
//

#import <UIKit/UIKit.h>
#import "NLHeaderModel.h"

NS_ASSUME_NONNULL_BEGIN

@class NLSongListHeaderView;

/**
 * HeaderView 的代理协议
 * 用于通知 VC 用户的操作和布局变化
 */
@protocol NLSongListHeaderViewDelegate <NSObject>

- (void)headerViewDidTapPlayAll:(NLSongListHeaderView *)headerView;
- (void)headerViewDidTapShuffle:(NLSongListHeaderView *)headerView;

@optional
- (void)headerViewDidRequestRelayout:(NLSongListHeaderView *)headerView;
@end


@interface NLSongListHeaderView : UIView

@property (nonatomic, weak) id<NLSongListHeaderViewDelegate> delegate;
@property (nonatomic, assign, readonly) BOOL isDescExpanded;
- (void)configWithPlayList:(NLHeaderModel *)playlist;

@end

NS_ASSUME_NONNULL_END
