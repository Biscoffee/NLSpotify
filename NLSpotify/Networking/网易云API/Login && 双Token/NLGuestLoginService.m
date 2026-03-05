//
//  NLGuestLoginService.m
//  NLSpotify
//
//  Created by 吴桐 on 2026/1/17.
//

#import "NLGuestLoginService.h"
#import "NetWorkManager.h"

@implementation NLGuestLoginService

+ (void)anonymousLoginWithSuccess:(void(^)(NSDictionary *))success
                          failure:(void(^)(NSError *))failure {
    NSString *path = @"/register/anonimous";
    [[NetWorkManager sharedManager] GET:path parameters:nil success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = responseObject;
            NSInteger code = [response[@"code"] integerValue];
            if (code == 200) {
                NSString *cookie = response[@"cookie"];
                // NSLog(@"[NLGuestLoginService] 接口成功 code=200，取到 cookie: %@，长度=%lu", cookie.length > 0 ? @"是" : @"否", (unsigned long)(cookie.length)); // 专注播放器时先注释
                if (success) success(response);
            } else {
                NSString *errorMsg = response[@"message"] ?: @"游客登录失败";
                NSError *error = [NSError errorWithDomain:@"NLGuestLoginService"
                                                     code:code
                                                 userInfo:@{NSLocalizedDescriptionKey: errorMsg}];
                if (failure) failure(error);
            }
        } else {
            NSError *error = [NSError errorWithDomain:@"NLGuestLoginService"
                                                 code:-1
                                             userInfo:@{NSLocalizedDescriptionKey: @"数据格式错误"}];
            if (failure) failure(error);
        }
    } failure:^(NSError *error) {
        if (failure) failure(error);
    }];
}

@end
