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

/// 当前 cookie，未登录为 nil
+ (NSString * _Nullable)currentCookie;
/// 设置 cookie（登录/游客登录/refresh 成功后调用）
+ (void)setCookie:(NSString * _Nullable)cookie;

/// 登录成功后更新状态（仅一种登录方式：游客；account 可为 nil）
+ (void)setLoginStateWithAccount:(id _Nullable)account;
/// 是否已登录（依据 UserDefaults）
+ (BOOL)isLoggedIn;

/// 登出：清 cookie + 清登录状态
+ (void)logout;

@end

NS_ASSUME_NONNULL_END
