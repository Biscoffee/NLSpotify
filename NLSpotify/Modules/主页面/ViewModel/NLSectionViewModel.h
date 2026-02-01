//
//  NLSectionViewModel.h
//  NLSpotify
//
//  Created by 吴桐 on 2025/12/13.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, NLHomeSectionStyle) {
  NLHomeSectionStylePlayListSmall,
  NLHomeSectionStylePlayListBig,
  NLHomeSectionStyleRecommend,
  NLHomeSectionStyleSeries,
  NLHomeSectionStyleSingle,
  NLHomeSectionStyleVideo
};

NS_ASSUME_NONNULL_BEGIN

@interface NLSectionViewModel : NSObject

@property (nonatomic, assign, readonly) NLHomeSectionStyle style;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSArray *items;

- (instancetype)initWithStyle:(NLHomeSectionStyle)style title:(NSString *)title items:(NSArray *)items;
+(id) sectionWithStyle:(NLHomeSectionStyle)style
                  title:(NSString *)title
                 items:(NSArray *)items;

@end

NS_ASSUME_NONNULL_END
