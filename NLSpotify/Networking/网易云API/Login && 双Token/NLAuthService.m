//
//  NLAuthService.m
//  NLSpotify
//
//  Created by 吴桐 on 2026/2/25.
//

#import "NLAuthService.h"
#import "NLAuthManager.h"
#import "NetWorkManager.h"

@implementation NLAuthService

+ (void)refreshLoginWithSuccess:(void(^)(void))success
                        failure:(void(^)(NSError *error))failure {
    NSString *path = @"/login/refresh";
    [[NetWorkManager sharedManager] GET:path parameters:nil success:^(id responseObject) {
        if (![responseObject isKindOfClass:[NSDictionary class]]) {
            if (failure) failure(nil);
            return;
        }
        NSDictionary *resp = responseObject;
        NSInteger code = [resp[@"code"] integerValue];
        if (code == 200) {
            NSString *cookie = resp[@"cookie"];
            if (cookie.length > 0) {
                [NLAuthManager setCookie:cookie];
            }
            if (success) success();
        } else {
            if (failure) failure(nil);
        }
    } failure:^(NSError *error) {
        if (failure) failure(error);
    }];
}
@end
