//
//  NLCommentTextFolder.h
//  NLSpotify
//
//  Created by 吴桐 on 2026/2/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NLCommentTextFolder : NSObject

+ (BOOL)textNeedExpand:(NSString *)text
                 width:(CGFloat)width
                  font:(UIFont *)font;


+ (NSAttributedString *)collapsedText:(NSString *)text
                                  font:(UIFont *)font
                                 width:(CGFloat)width;

+ (NSAttributedString *)expandedText:(NSString *)text
                                 font:(UIFont *)font;

@end

NS_ASSUME_NONNULL_END
