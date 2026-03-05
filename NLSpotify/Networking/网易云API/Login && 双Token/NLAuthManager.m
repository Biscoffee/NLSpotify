//
//  NLAuthManager.m
//  NLSpotify
//

#import "NLAuthManager.h"

NSNotificationName const NLForceLogoutNotification = @"NLForceLogoutNotification";
static NSString * const kCookieKey       = @"NLNeteaseCookie";
static NSString * const kIsLoggedInKey   = @"isLoggedIn";
static NSString * const kUserAccountKey  = @"userAccount";

@implementation NLAuthManager
+ (NSString *)currentCookie {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kCookieKey];
}
+ (void)setCookie:(NSString *)cookie {
    if (cookie.length) {
        [[NSUserDefaults standardUserDefaults] setObject:cookie forKey:kCookieKey];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCookieKey];
    }
}
+ (void)setLoginStateWithAccount:(id)account {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsLoggedInKey];
    if (account) [[NSUserDefaults standardUserDefaults] setObject:account forKey:kUserAccountKey];
}
+ (BOOL)isLoggedIn {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kIsLoggedInKey];
}
+ (void)logout {
    [self setCookie:nil];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kIsLoggedInKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserAccountKey];
}

@end
