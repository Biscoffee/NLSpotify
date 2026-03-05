//
//  NLHomeSectionHeaderView.h
//  NLSpotify
//

#import <UIKit/UIKit.h>

@class NLSectionViewModel;

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT const CGFloat NLHomeSectionHeaderHeight;

@interface NLHomeSectionHeaderView : UITableViewHeaderFooterView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *disclosureImageView;
@property (nonatomic, assign) NSInteger sectionIndex;
@property (nonatomic, assign) BOOL collapsed;
@property (nonatomic, copy, nullable) void (^didTapHeader)(NSInteger sectionIndex);

- (void)configWithTitle:(NSString *)title collapsed:(BOOL)collapsed;
/// 使用 section 数据配置：普通 section 显示 title；林俊杰等歌手 section 显示头像 +「的粉丝特供」+ 歌手名
- (void)configWithSectionVM:(NLSectionViewModel *)sectionVM collapsed:(BOOL)collapsed;

@end

NS_ASSUME_NONNULL_END
