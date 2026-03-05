//
//  NLDrawerView.h
//  NLSpotify
//
//  抽屉视图 View（MVC - View）：仅负责展示与事件上报
//

#import <UIKit/UIKit.h>

@class NLDrawerView, NLDrawerProfileModel, NLDrawerMenuItem, NLDrawerMessageSectionModel;

NS_ASSUME_NONNULL_BEGIN

@protocol NLDrawerViewDelegate <NSObject>
@optional
- (void)drawerView:(NLDrawerView *)drawerView didSelectMenuAtIndex:(NSInteger)index;
@end

@interface NLDrawerView : UIView

@property (nonatomic, weak, nullable) id<NLDrawerViewDelegate> delegate;

- (void)configWithProfile:(NLDrawerProfileModel *)profile
               menuItems:(NSArray<NLDrawerMenuItem *> *)menuItems
          messageSection:(NLDrawerMessageSectionModel *)messageSection;

@end

NS_ASSUME_NONNULL_END
