//
//  NLExpandableTouchSlider.h
//  NLSpotify
//
//  Created by 吴桐 on 2026/3/3.
//

#import <UIKit/UIKit.h>

/// 支持自定义触摸热区扩展的 Slider
@interface NLExpandableTouchSlider : UISlider

/// 向外扩展的点击区域大小（默认 15pt）
@property (nonatomic, assign) CGFloat touchAreaExpansion;

@end
