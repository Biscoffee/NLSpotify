//
//  AppDelegate.m
//  NLSpotify
//
//  Created by 吴桐 on 2025/12/6.
//

#import "AppDelegate.h"
#import "NLHomeViewController.h"
#import "NLTabBarController.h"
#import "NLDataBaseManager.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [NLDataBaseManager sharedManager];
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;

        // (可选附加魔法：点击屏幕空白处自动收起键盘，极其好用)
        [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
  return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
  // Called when a new scene session is being created.
  // Use this method to select a configuration to create the new scene with.
  return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
  // Called when the user discards a scene session.
  // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
  // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
