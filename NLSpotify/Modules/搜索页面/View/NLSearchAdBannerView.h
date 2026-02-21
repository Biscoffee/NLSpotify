//  NLSearchAdBannerView.h
//  NLSpotify
//
//  顶部 Apple Music 风格广告视图（纯 View，不含导航逻辑）
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NLSearchAdBannerView : UIView

/// 点击「立即体验」
@property (nonatomic, copy, nullable) void (^onExperienceTapped)(void);
/// 点击右上角关闭
@property (nonatomic, copy, nullable) void (^onCloseTapped)(void);

@end

NS_ASSUME_NONNULL_END

