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

@protocol NLSongListHeaderViewDelegate <NSObject>
- (void)headerViewDidTapPlayAll:(NLSongListHeaderView *)headerView;
- (void)headerViewDidTapDownload:(NLSongListHeaderView *)headerView;
- (void)headerViewDidTapSort:(NLSongListHeaderView *)headerView;
- (void)headerView:(NLSongListHeaderView *)headerView didTapTopAction:(NSString *)type;
@end

@interface NLSongListHeaderView : UIView

@property (nonatomic, weak) id<NLSongListHeaderViewDelegate> delegate;

// 暴露 artistImageView 只用于对齐（你已经用得很对）
@property (nonatomic, strong, readonly) UIImageView *artistImageView;

- (void)configWithPlayList:(NLHeaderModel *)playlist;

@end

NS_ASSUME_NONNULL_END
