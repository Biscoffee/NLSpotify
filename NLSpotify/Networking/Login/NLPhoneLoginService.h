//
//  NLPhoneLoginService.h
//  NLSpotify
//
//  Created by 吴桐 on 2026/1/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NLPhoneLoginService : NSObject

/**
 手机号密码登录
 @param phone 手机号码
 @param password 密码
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)loginWithPhone:(NSString *)phone
              password:(NSString *)password
               success:(void(^)(NSDictionary *response))success
               failure:(void(^)(NSError *error))failure;

/**
 手机号验证码登录
 @param phone 手机号码
 @param captcha 验证码
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)loginWithPhone:(NSString *)phone
               captcha:(NSString *)captcha
               success:(void(^)(NSDictionary *response))success
               failure:(void(^)(NSError *error))failure;

/**
 获取验证码
 @param phone 手机号码
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)sendCaptchaWithPhone:(NSString *)phone
                     success:(void(^)(NSDictionary *response))success
                     failure:(void(^)(NSError *error))failure;

/**
 检查验证码
 @param phone 手机号码
 @param captcha 验证码
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)verifyCaptchaWithPhone:(NSString *)phone
                       captcha:(NSString *)captcha
                       success:(void(^)(NSDictionary *response))success
                       failure:(void(^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
