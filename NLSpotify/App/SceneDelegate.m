//
//  SceneDelegate.m
//  NLSpotify
//
//  Created by 吴桐 on 2025/12/6.
//

#import "SceneDelegate.h"
#import "NLTabBarController.h"
#import "NLLoginViewController.h"

@interface SceneDelegate ()

@end

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    self.window = [[UIWindow alloc] initWithWindowScene:windowScene];

    // 检查登录状态
    BOOL isLoggedIn = [[NSUserDefaults standardUserDefaults] boolForKey:@"isLoggedIn"];

    if (isLoggedIn) {
        // 已登录，直接进入主页面
        NLTabBarController *tabBar = [[NLTabBarController alloc] init];
        self.window.rootViewController = tabBar;
    } else {
        // 未登录，显示登录页面
        NLLoginViewController *loginVC = [[NLLoginViewController alloc] init];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginVC];
        navController.navigationBarHidden = YES;
        self.window.rootViewController = navController;
    }

    [self.window makeKeyAndVisible];
}

// 添加退出登录的方法
- (void)logout {
    // 清除登录状态
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isLoggedIn"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    // 切换到登录页面
    NLLoginViewController *loginVC = [[NLLoginViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginVC];
    navController.navigationBarHidden = YES;

    // 动画切换
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    transition.type = kCATransitionFade;

    [self.window.layer addAnimation:transition forKey:kCATransition];
    self.window.rootViewController = navController;
}


- (void)sceneDidDisconnect:(UIScene *)scene {
  // Called as the scene is being released by the system.
  // This occurs shortly after the scene enters the background, or when its session is discarded.
  // Release any resources associated with this scene that can be re-created the next time the scene connects.
  // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
}


- (void)sceneDidBecomeActive:(UIScene *)scene {
  // Called when the scene has moved from an inactive state to an active state.
  // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
}


- (void)sceneWillResignActive:(UIScene *)scene {
  // Called when the scene will move from an active state to an inactive state.
  // This may occur due to temporary interruptions (ex. an incoming phone call).
}


- (void)sceneWillEnterForeground:(UIScene *)scene {
  // Called as the scene transitions from the background to the foreground.
  // Use this method to undo the changes made on entering the background.
}


- (void)sceneDidEnterBackground:(UIScene *)scene {
  // Called as the scene transitions from the foreground to the background.
  // Use this method to save data, release shared resources, and store enough scene-specific state information
  // to restore the scene back to its current state.
}


@end
