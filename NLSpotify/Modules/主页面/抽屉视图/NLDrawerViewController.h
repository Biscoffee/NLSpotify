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
- (void)drawerControllerDidTapProfile:(NLDrawerViewController *)controller;
- (void)drawerControllerDidTapStatusButton:(NLDrawerViewController *)controller;
- (void)drawerControllerDidTapNewMessage:(NLDrawerViewController *)controller;
@end

@interface NLDrawerViewController : UIViewController

@property (nonatomic, copy, nullable) void (^onRequestClose)(void);
@property (nonatomic, weak, nullable) id<NLDrawerViewControllerDelegate> delegate;
/// 关闭并移除后回调（便于宿主将引用置 nil）
@property (nonatomic, copy, nullable) void (^onDidDismiss)(void);

/// 从指定宿主 VC 上展示抽屉（添加为 child，播打开动画）
- (void)presentFromHostViewController:(UIViewController *)host;
/// 关闭抽屉并移除自己
- (void)dismissWithAnimation:(BOOL)animated completion:(nullable void (^)(void))completion;

@end

NS_ASSUME_NONNULL_END
