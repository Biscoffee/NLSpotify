//
//  NLDrawerViewController.h
//  NLSpotify
//
//  抽屉 VC：内容（NLDrawerView）+ 遮罩 + 展示/关闭动画，一个 VC 搞定
//

#import <UIKit/UIKit.h>

@class NLDrawerViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol NLDrawerViewControllerDelegate <NSObject>
@optional
- (void)drawerController:(NLDrawerViewController *)controller didSelectMenuAtIndex:(NSInteger)index;
@end

@interface NLDrawerViewController : UIViewController

@property (nonatomic, weak, nullable) id<NLDrawerViewControllerDelegate> delegate;
@property (nonatomic, copy, nullable) void (^drawrDidDismiss)(void);

- (void)presentFromHostViewController:(UIViewController *)host;
- (void)dismissWithAnimation:(BOOL)animated completion:(nullable void (^)(void))completion;

@end

NS_ASSUME_NONNULL_END
