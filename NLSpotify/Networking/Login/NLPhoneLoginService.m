//
//  NLPhoneLoginService.m
//  NLSpotify
//
//  Created by 吴桐 on 2026/1/17.
//

#import "NLPhoneLoginService.h"
#import "NetWorkManager.h"

@implementation NLPhoneLoginService

#pragma mark - 手机号密码登录
+ (void)loginWithPhone:(NSString *)phone
              password:(NSString *)password
               success:(void(^)(NSDictionary *))success
               failure:(void(^)(NSError *))failure {

    NSString *path = @"/login/cellphone";

    // 参数验证
    if (!phone || phone.length == 0) {
        NSError *error = [NSError errorWithDomain:@"NLPhoneLoginService"
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey: @"请输入手机号"}];
        if (failure) failure(error);
        return;
    }

    if (!password || password.length == 0) {
        NSError *error = [NSError errorWithDomain:@"NLPhoneLoginService"
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey: @"请输入密码"}];
        if (failure) failure(error);
        return;
    }

    // 构建参数
    NSDictionary *params = @{
        @"phone": phone,
        @"password": password
    };

    [[NetWorkManager sharedManager] GET:path parameters:params success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = responseObject;

            // 检查响应码
            NSInteger code = [response[@"code"] integerValue];
            if (code == 200) {
                if (success) success(response);
            } else {
                NSString *errorMsg = response[@"message"] ?: @"登录失败";
                NSError *error = [NSError errorWithDomain:@"NLPhoneLoginService"
                                                     code:code
                                                 userInfo:@{NSLocalizedDescriptionKey: errorMsg}];
                if (failure) failure(error);
            }
        } else {
            NSError *error = [NSError errorWithDomain:@"NLPhoneLoginService"
                                                 code:-1
                                             userInfo:@{NSLocalizedDescriptionKey: @"数据格式错误"}];
            if (failure) failure(error);
        }
    } failure:^(NSError *error) {
        if (failure) failure(error);
    }];
}

#pragma mark - 手机号验证码登录
+ (void)loginWithPhone:(NSString *)phone
               captcha:(NSString *)captcha
               success:(void(^)(NSDictionary *))success
               failure:(void(^)(NSError *))failure {

    NSString *path = @"/login/cellphone";

    // 参数验证
    if (!phone || phone.length == 0) {
        NSError *error = [NSError errorWithDomain:@"NLPhoneLoginService"
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey: @"请输入手机号"}];
        if (failure) failure(error);
        return;
    }

    if (!captcha || captcha.length == 0) {
        NSError *error = [NSError errorWithDomain:@"NLPhoneLoginService"
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey: @"请输入验证码"}];
        if (failure) failure(error);
        return;
    }

    // 构建参数
    NSDictionary *params = @{
        @"phone": phone,
        @"captcha": captcha
    };

    [[NetWorkManager sharedManager] POST:path
                              parameters:params
                                 success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = responseObject;

            NSInteger code = [response[@"code"] integerValue];
            if (code == 200) {
                if (success) success(response);
            } else {
                NSString *errorMsg = response[@"message"] ?: @"登录失败";
                NSError *error = [NSError errorWithDomain:@"NLPhoneLoginService"
                                                     code:code
                                                 userInfo:@{NSLocalizedDescriptionKey: errorMsg}];
                if (failure) failure(error);
            }
        } else {
            NSError *error = [NSError errorWithDomain:@"NLPhoneLoginService"
                                                 code:-1
                                             userInfo:@{NSLocalizedDescriptionKey: @"数据格式错误"}];
            if (failure) failure(error);
        }
    } failure:^(NSError *error) {
        if (failure) failure(error);
    }];
}

#pragma mark - 发送验证码
+ (void)sendCaptchaWithPhone:(NSString *)phone
                     success:(void(^)(NSDictionary *))success
                     failure:(void(^)(NSError *))failure {

    NSString *path = @"/captcha/sent";

    if (!phone || phone.length == 0) {
        NSError *error = [NSError errorWithDomain:@"NLPhoneLoginService"
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey: @"请输入手机号"}];
        if (failure) failure(error);
        return;
    }

    NSDictionary *params = @{@"phone": phone};

    [[NetWorkManager sharedManager] GET:path parameters:params success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = responseObject;

            NSInteger code = [response[@"code"] integerValue];
            if (code == 200) {
                if (success) success(response);
            } else {
                NSString *errorMsg = response[@"message"] ?: @"发送验证码失败";
                NSError *error = [NSError errorWithDomain:@"NLPhoneLoginService"
                                                     code:code
                                                 userInfo:@{NSLocalizedDescriptionKey: errorMsg}];
                if (failure) failure(error);
            }
        } else {
            NSError *error = [NSError errorWithDomain:@"NLPhoneLoginService"
                                                 code:-1
                                             userInfo:@{NSLocalizedDescriptionKey: @"数据格式错误"}];
            if (failure) failure(error);
        }
    } failure:^(NSError *error) {
        if (failure) failure(error);
    }];
}

#pragma mark - 验证验证码
+ (void)verifyCaptchaWithPhone:(NSString *)phone
                       captcha:(NSString *)captcha
                       success:(void(^)(NSDictionary *))success
                       failure:(void(^)(NSError *))failure {

    NSString *path = @"/captcha/verify";

    if (!phone || phone.length == 0) {
        NSError *error = [NSError errorWithDomain:@"NLPhoneLoginService"
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey: @"请输入手机号"}];
        if (failure) failure(error);
        return;
    }

    if (!captcha || captcha.length == 0) {
        NSError *error = [NSError errorWithDomain:@"NLPhoneLoginService"
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey: @"请输入验证码"}];
        if (failure) failure(error);
        return;
    }

    NSDictionary *params = @{
        @"phone": phone,
        @"captcha": captcha
    };

    [[NetWorkManager sharedManager] GET:path parameters:params success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = responseObject;

            NSInteger code = [response[@"code"] integerValue];
            if (code == 200) {
                if (success) success(response);
            } else {
                NSString *errorMsg = response[@"message"] ?: @"验证码错误";
                NSError *error = [NSError errorWithDomain:@"NLPhoneLoginService"
                                                     code:code
                                                 userInfo:@{NSLocalizedDescriptionKey: errorMsg}];
                if (failure) failure(error);
            }
        } else {
            NSError *error = [NSError errorWithDomain:@"NLPhoneLoginService"
                                                 code:-1
                                             userInfo:@{NSLocalizedDescriptionKey: @"数据格式错误"}];
            if (failure) failure(error);
        }
    } failure:^(NSError *error) {
        if (failure) failure(error);
    }];
}

@end
