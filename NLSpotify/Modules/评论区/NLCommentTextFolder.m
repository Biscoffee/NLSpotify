//
//  NLCommentTextFolder.m
//  NLSpotify
//
//  Created by 吴桐 on 2026/2/21.
//

#import "NLCommentTextFolder.h"

@implementation NLCommentTextFolder

+ (BOOL)textNeedExpand:(NSString *)text
                 width:(CGFloat)width
                  font:(UIFont *)font {
    if (!text || text.length == 0) return NO;
    if (!font) font = [UIFont systemFontOfSize:15];
    //创建富文本
    NSDictionary *attrs = @{NSFontAttributeName: font};
    NSAttributedString *attStr = [[NSAttributedString alloc] initWithString:text attributes:attrs];

    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:attStr];//textKit组件，
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    NSTextContainer *textContainer =
    [[NSTextContainer alloc] initWithSize:CGSizeMake(width, CGFLOAT_MAX)];

    textContainer.lineFragmentPadding = 0;

    [textStorage addLayoutManager:layoutManager];
    [layoutManager addTextContainer:textContainer];

    [layoutManager glyphRangeForTextContainer:textContainer];

    NSUInteger glyphCount = layoutManager.numberOfGlyphs;

    NSUInteger lineCount = 0;
    NSUInteger index = 0;

    while (index < glyphCount) {

        NSRange lineRange;

        [layoutManager lineFragmentRectForGlyphAtIndex:index
                                        effectiveRange:&lineRange];

        index = NSMaxRange(lineRange);

        lineCount++;
    }

    return lineCount > 3;
}

+ (NSAttributedString *)collapsedText:(NSString *)text
                                 font:(UIFont *)font
                                width:(CGFloat)width {
    if (!text || text.length == 0) {
        return [[NSAttributedString alloc] initWithString:@""];
    }
    if (!font) font = [UIFont systemFontOfSize:15];
    
    NSString *suffix = @"...展开";

    NSDictionary *attrs = @{NSFontAttributeName:font};

    NSAttributedString *attrStr =
    [[NSAttributedString alloc] initWithString:text attributes:attrs];

    NSTextStorage *textStorage =
    [[NSTextStorage alloc] initWithAttributedString:attrStr];

    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];

    NSTextContainer *textContainer =
    [[NSTextContainer alloc] initWithSize:CGSizeMake(width, CGFLOAT_MAX)];

    textContainer.lineFragmentPadding = 0;

    [textStorage addLayoutManager:layoutManager];
    [layoutManager addTextContainer:textContainer];

    [layoutManager glyphRangeForTextContainer:textContainer];

    NSUInteger glyphCount = layoutManager.numberOfGlyphs;

    NSUInteger line = 0;
    NSUInteger index = 0;

    while (index < glyphCount) {

        NSRange lineRange;

        [layoutManager lineFragmentRectForGlyphAtIndex:index
                                        effectiveRange:&lineRange];

        line++;

        if (line == 3) {

            NSUInteger endIndex = NSMaxRange(lineRange);

            if (endIndex >= suffix.length) {
                endIndex -= suffix.length;
            }

            NSString *subText =
            [text substringWithRange:[text rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, endIndex)]];

            NSString *result =
            [NSString stringWithFormat:@"%@%@", subText, suffix];

            NSMutableAttributedString *attr =
            [[NSMutableAttributedString alloc] initWithString:result];

            [attr addAttribute:NSFontAttributeName
                         value:font
                         range:NSMakeRange(0, attr.length)];

            [attr addAttribute:NSForegroundColorAttributeName
                         value:[UIColor systemBlueColor]
                         range:NSMakeRange(attr.length - suffix.length,
                                           suffix.length)];

            return attr;
        }

        index = NSMaxRange(lineRange);
    }

    return attrStr;
}

#pragma mark - 展开文本

+ (NSAttributedString *)expandedText:(NSString *)text
                                 font:(UIFont *)font {
    if (!text) text = @"";
    if (!font) font = [UIFont systemFontOfSize:15];
    
    NSString *suffix = @" 收起";
    NSString *result = [NSString stringWithFormat:@"%@%@", text, suffix];

    NSMutableAttributedString *attr =
    [[NSMutableAttributedString alloc] initWithString:result];

    [attr addAttribute:NSFontAttributeName
                 value:font
                 range:NSMakeRange(0, attr.length)];

    [attr addAttribute:NSForegroundColorAttributeName
                 value:[UIColor systemBlueColor]
                 range:NSMakeRange(attr.length - suffix.length,
                                   suffix.length)];

    return attr;
}

@end
