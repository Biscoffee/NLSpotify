//
//  NetWorkManager.m
//  NLSpotify
//
//  Created by 吴桐 on 2025/12/15.
//

#import "NetWorkManager.h"
#import "AFNetworking/AFNetworking.h"

static NSString * const kBaseURL = @"https://1390963969-2g6ivueiij.ap-guangzhou.tencentscf.com";

@interface NetWorkManager ()
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@end

@implementation NetWorkManager

+ (id)sharedManager {
    static NetWorkManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[NetWorkManager alloc] init];
        [manager setupSessionManager];
    });
    return manager;
}

- (void)setupSessionManager {
    _sessionManager = [AFHTTPSessionManager manager];
    _sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    _sessionManager.requestSerializer.timeoutInterval = 20;
}

- (void)GET:(NSString *)path parameters:(NSDictionary *)params success:(SuccessBlock)success failure:(FailureBlock)failure {
    NSString *url = [kBaseURL stringByAppendingString:path];
    [self.sessionManager GET:url parameters:params headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if (httpResponse) {
            NSLog(@"[NetWork] GET 失败 statusCode=%ld path=%@ params=%@", (long)httpResponse.statusCode, path, params ?: @{});
        }
        if (failure) failure(error);
    }];
}

-(void)POST:(NSString *)path parameters:(NSDictionary *)params success:(SuccessBlock)success failure:(FailureBlock)failure {
    NSString *url = [kBaseURL stringByAppendingString:path];
    [self.sessionManager POST:url parameters:params headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if (httpResponse) {
            NSLog(@"[NetWork] POST 失败 statusCode=%ld path=%@ params=%@", (long)httpResponse.statusCode, path, params ?: @{});
        }
        if(failure) failure(error);
    }];
}

@end
