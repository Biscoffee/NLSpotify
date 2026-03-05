//
//  NLAuthManager.h
//  NLSpotify
//
//  统一管理登录凭证（cookie）、登录状态与登出，双 token 时 refresh 成功后也通过此处写回 cookie。
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 强制登出（如 refresh 失败、重试仍 401 等），监听后应切到登录页
FOUNDATION_EXPORT NSNotificationName const NLForceLogoutNotification;

@interface NLAuthManager : NSObject
+ (NSString * _Nullable)currentCookie;
+ (void)setCookie:(NSString * _Nullable)cookie;
+ (void)setLoginStateWithAccount:(id _Nullable)account;
+ (BOOL)isLoggedIn;
+ (void)logout;

@end

NS_ASSUME_NONNULL_END
