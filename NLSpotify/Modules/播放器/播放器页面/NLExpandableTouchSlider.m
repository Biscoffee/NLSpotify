//
//  NLExpandableTouchSlider.m
//  NLSpotify
//
//  Created by 吴桐 on 2026/3/3.
//

#import "NLExpandableTouchSlider.h"

@implementation NLExpandableTouchSlider

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _touchAreaExpansion = 50.0;

        // 在这里直接把 Normal 和 Highlighted 的滑块全部干掉！
        // 以后外面调用这个类，再也不会出现那个巨型圆球了
        [self setThumbImage:[UIImage new] forState:UIControlStateNormal];
        [self setThumbImage:[UIImage new] forState:UIControlStateHighlighted];
    }
    return self;
}

// 隐形扩大触摸结界
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect bounds = self.bounds;
    // 负数表示向外扩张
    CGRect expandedBounds = CGRectInset(bounds, -self.touchAreaExpansion, -self.touchAreaExpansion);
    return CGRectContainsPoint(expandedBounds, point);
}

// 辅助方法：将手指的屏幕坐标，换算成 0.0 ~ 1.0 的进度值
- (float)valueForTouch:(UITouch *)touch {
    CGPoint point = [touch locationInView:self];
    float percentage = point.x / self.bounds.size.width;
    // 严防死守：限制在 0.0 到 1.0 之间，防止越界
    percentage = MAX(0.0, MIN(1.0, percentage));
    return self.minimumValue + percentage * (self.maximumValue - self.minimumValue);
}

// 手指刚刚按下的瞬间 (不管点在哪，直接把进度传送过来)
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    // 瞬间传送进度点！加上 animated:YES 会有一个很丝滑的飞过去的效果
    float tapValue = [self valueForTouch:touch];
    [self setValue:tapValue animated:YES];

    // 告诉外部：我的值变了！
    [self sendActionsForControlEvents:UIControlEventValueChanged];

    // 返回 YES 代表“虽然我没点中那个隐形滑块，但接下来的拖拽我强行接管
    return YES;
}

// 手指滑动中 
- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    float tapValue = [self valueForTouch:touch];
    // 滑动时不需要动画，直接赋值，保证手指和进度点 1:1 绝对黏合
    [self setValue:tapValue animated:NO];

    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}

// (不需要重写 endTrackingWithTouch，因为父类 UIControl 在松手时会自动帮我们触发 TouchUpInside 事件)
@end
