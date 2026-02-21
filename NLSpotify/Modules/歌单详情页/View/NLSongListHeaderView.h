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

/** 用户点击「播放」按钮，顺序播放歌单 */
- (void)headerViewDidTapPlayAll:(NLSongListHeaderView *)headerView;

/** 用户点击「随机播放」按钮，打乱顺序后播放 */
- (void)headerViewDidTapShuffle:(NLSongListHeaderView *)headerView;

@optional
/** 简介展开/收起时，请求 VC 重新计算 headerView 高度 */
- (void)headerViewDidRequestRelayout:(NLSongListHeaderView *)headerView;
@end


@interface NLSongListHeaderView : UIView

@property (nonatomic, weak) id<NLSongListHeaderViewDelegate> delegate;

/** 简介是否已展开（只读） */
@property (nonatomic, assign, readonly) BOOL isDescExpanded;

/**
 * 配置 headerView 的数据
 * @param playlist 歌单/专辑的头部信息（封面、标题、简介等）
 */
- (void)configWithPlayList:(NLHeaderModel *)playlist;

@end

NS_ASSUME_NONNULL_END
