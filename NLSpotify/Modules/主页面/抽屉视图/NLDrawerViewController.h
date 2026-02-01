//
//  NLDrawerViewController.h
//  NLSpotify
//
//  抽屉 Controller（MVC - Controller）：持有 View 和 Model，转发事件给宿主
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

@end

NS_ASSUME_NONNULL_END
