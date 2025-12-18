//
//  NLTabBarController.m
//  NLSpotify
//
//  Created by 吴桐 on 2025/12/14.
//

#import "NLTabBarController.h"

#import "NLAdvertiseViewController.h"
#import "NLCreateViewController.h"
#import "NLMusicViewController.h"
#import "NLSearchViewController.h"
#import "NLHomeViewController.h"

@interface NLTabBarController () <UITabBarControllerDelegate>
@end

@implementation NLTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];

    UITab *homeTab = [[UITab alloc] initWithTitle:@"首页"
                                            image:[UIImage systemImageNamed:@"house"]
                                       identifier:@"Home"
                           viewControllerProvider:^UIViewController * _Nonnull(UITab * _Nonnull tab) {
        NLHomeViewController *homeVC = [[NLHomeViewController alloc] init];
        return [[UINavigationController alloc] initWithRootViewController:homeVC];
    }];
    UITab *musicTab = [[UITab alloc] initWithTitle:@"音乐库"
                                             image:[UIImage systemImageNamed:@"music.pages"]
                                        identifier:@"MusicLibrary"
                            viewControllerProvider:^UIViewController * _Nonnull(UITab * _Nonnull tab) {
        NLMusicViewController *musicVC = [[NLMusicViewController alloc] init];
        return [[UINavigationController alloc] initWithRootViewController:musicVC];
    }];

    UITab *premiumTab = [[UITab alloc] initWithTitle:@"Premium"
                                               image:[UIImage systemImageNamed:@"yensign"]
                                          identifier:@"Premium"
                              viewControllerProvider:^UIViewController * _Nonnull(UITab * _Nonnull tab) {
        NLAdvertiseViewController *premiumVC = [[NLAdvertiseViewController alloc] init];
        return [[UINavigationController alloc] initWithRootViewController:premiumVC];
    }];

    UITab *createTab = [[UITab alloc] initWithTitle:@"创建"
                                              image:[UIImage systemImageNamed:@"plus"]
                                         identifier:@"Create"
                             viewControllerProvider:^UIViewController * _Nonnull(UITab * _Nonnull tab) {
        NLCreateViewController *createVC = [[NLCreateViewController alloc] init];
        return [[UINavigationController alloc] initWithRootViewController:createVC];
    }];

    // 创建UISearchTab
    UISearchTab *searchTab = [[UISearchTab alloc] initWithViewControllerProvider:^UIViewController * _Nonnull(UITab * _Nonnull tab) {
        NLSearchViewController *searchVC = [[NLSearchViewController alloc] init];
        // 封装到导航控制器，保持页面跳转能力
        UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:searchVC];
        return navVC;
    }];
    // 配置UISearchTab的属性（参考代码的设置）
    searchTab.automaticallyActivatesSearch = YES; // 自动激活搜索
    //searchTab.placeholder = @"搜索歌曲、歌手、专辑"; // 搜索框占位符（可选）
    searchTab.title = @"搜索"; // 搜索标签的标题（可选）
    searchTab.image = [UIImage systemImageNamed:@"magnifyingglass"]; // 搜索标签的图标（可选）

    // 6. 将所有标签（UITab + UISearchTab）加入tabs属性（iOS 17+关键）
    self.tabs = @[homeTab, musicTab, premiumTab, createTab, searchTab];
    self.delegate = self; // 设置代理
    self.tabBar.tintColor = [UIColor blackColor]; // 选中颜色（你原来的设置）
    self.tabBar.unselectedItemTintColor = [UIColor grayColor]; // 未选中颜色（你原来的设置）
    self.tabBar.layer.borderWidth = 0; // 隐藏标签栏边框
    self.tabBarMinimizeBehavior = UITabBarMinimizeBehaviorOnScrollDown; // 滚动时最小化标签栏
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    // 打印选中的控制器，方便调试
    NSLog(@"didSelectViewController: %@", viewController);
    // 点击反馈（参考代码的震动效果）
    UIImpactFeedbackGenerator *feedbackGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
    [feedbackGenerator prepare];
    [feedbackGenerator impactOccurred];
}

@end
