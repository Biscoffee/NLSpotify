//
//  NLExpandableTouchSlider.m
//  NLSpotify
//
//  Created by 吴桐 on 2025/12/19.
//

#import "NLExpandableTouchSlider.h"

@implementation NLExpandableTouchSlider

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect expandedBounds = CGRectInset(self.bounds, 0, -20);
    return CGRectContainsPoint(expandedBounds, point);
}

@end
