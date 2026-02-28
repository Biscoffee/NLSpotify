//
//  NetWorkManager.m
//  NLSpotify
//
//  Created by 吴桐 on 2025/12/15.
//

#import "NetWorkManager.h"
#import "AFNetworking/AFNetworking.h"
#import "NLAuthManager.h"
#import "NLAuthService.h"

static NSString * const kBaseURL = @"https://1390963969-2g6ivueiij.ap-guangzhou.tencentscf.com";
static const NSInteger kMaxRetryCount = 1;

@interface NLPendingAuthRequest : NSObject
@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSDictionary *params;
@property (nonatomic, assign) BOOL isGET;
@property (nonatomic, copy) SuccessBlock success;
@property (nonatomic, copy) FailureBlock failure;
@end

@implementation NLPendingAuthRequest
@end

@interface NetWorkManager ()
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, strong) NSMutableArray<NLPendingAuthRequest *> *pendingRequests;
@property (nonatomic, strong) dispatch_queue_t refreshLockQueue;
@end

@implementation NetWorkManager

/// 带 cookie 的请求头（自动从 NLAuthManager 取，无 cookie 时返回空 dict）
+ (NSDictionary *)requestHeadersWithCookie {
    NSString *cookie = [NLAuthManager currentCookie];
    if (cookie.length == 0) return @{};
    return @{ @"Cookie": cookie };
}


+ (id)sharedManager {
    static NetWorkManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[NetWorkManager alloc] init];
        [manager setupSessionManager];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        _pendingRequests = [NSMutableArray array];
        _refreshLockQueue = dispatch_queue_create("com.nlspotify.network.refresh", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)setupSessionManager {
    _sessionManager = [AFHTTPSessionManager manager];
    _sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    _sessionManager.requestSerializer.timeoutInterval = 20;
}

#pragma mark - Force logout & kick to login

- (void)forceLogoutAndFailWithError:(NSError *)error failure:(FailureBlock)failure {
    [NLAuthManager logout];
    [[NSNotificationCenter defaultCenter] postNotificationName:NLForceLogoutNotification object:nil];
    if (failure) failure(error);
}

- (void)forceLogoutAndKickToLogin {
    [NLAuthManager logout];
    [[NSNotificationCenter defaultCenter] postNotificationName:NLForceLogoutNotification object:nil];
}

#pragma mark - Public API (retryCount = 0)

- (void)GET:(NSString *)path parameters:(NSDictionary *)params success:(SuccessBlock)success failure:(FailureBlock)failure {
    [self GET:path parameters:params retryCount:0 success:success failure:failure];
}

- (void)POST:(NSString *)path parameters:(NSDictionary *)params success:(SuccessBlock)success failure:(FailureBlock)failure {
    [self POST:path parameters:params retryCount:0 success:success failure:failure];
}

#pragma mark - Internal with retryCount

- (void)GET:(NSString *)path parameters:(NSDictionary *)params retryCount:(NSInteger)retryCount success:(SuccessBlock)success failure:(FailureBlock)failure {
    NSString *url = [kBaseURL stringByAppendingString:path];
    NSDictionary *headers = [NetWorkManager requestHeadersWithCookie];
    __weak typeof(self) w = self;

    [self.sessionManager GET:url parameters:params headers:headers progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSInteger bizCode = [responseObject[@"code"] integerValue];
        if (bizCode == 301) {
            [w handleAuthRequiredForGET:path params:params retryCount:retryCount success:success failure:failure];
            return;
        }
        if (success) success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if (httpResponse && httpResponse.statusCode == 401) {
            [w handleAuthRequiredForGET:path params:params retryCount:retryCount success:success failure:failure];
            return;
        }
        if (httpResponse) {
            NSLog(@"[NetWork] GET 失败 statusCode=%ld path=%@", (long)httpResponse.statusCode, path);
        }
        if (failure) failure(error);
    }];
}

- (void)POST:(NSString *)path parameters:(NSDictionary *)params retryCount:(NSInteger)retryCount success:(SuccessBlock)success failure:(FailureBlock)failure {
    NSString *url = [kBaseURL stringByAppendingString:path];
    NSDictionary *headers = [NetWorkManager requestHeadersWithCookie];
    __weak typeof(self) w = self;

    [self.sessionManager POST:url parameters:params headers:headers progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSInteger bizCode = [responseObject[@"code"] integerValue];
        if (bizCode == 301) {
            [w handleAuthRequiredForPOST:path params:params retryCount:retryCount success:success failure:failure];
            return;
        }
        if (success) success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if (httpResponse && httpResponse.statusCode == 401) {
            [w handleAuthRequiredForPOST:path params:params retryCount:retryCount success:success failure:failure];
            return;
        }
        if (httpResponse) {
            NSLog(@"[NetWork] POST 失败 statusCode=%ld path=%@", (long)httpResponse.statusCode, path);
        }
        if (failure) failure(error);
    }];
}

#pragma mark - Auth required (301 / 401): refresh lock + queue

- (void)handleAuthRequiredForGET:(NSString *)path params:(NSDictionary *)params retryCount:(NSInteger)retryCount success:(SuccessBlock)success failure:(FailureBlock)failure {
    [self handleAuthRequiredWithPath:path params:params isGET:YES retryCount:retryCount success:success failure:failure];
}

- (void)handleAuthRequiredForPOST:(NSString *)path params:(NSDictionary *)params retryCount:(NSInteger)retryCount success:(SuccessBlock)success failure:(FailureBlock)failure {
    [self handleAuthRequiredWithPath:path params:params isGET:NO retryCount:retryCount success:success failure:failure];
}

- (void)handleAuthRequiredWithPath:(NSString *)path params:(NSDictionary *)params isGET:(BOOL)isGET retryCount:(NSInteger)retryCount success:(SuccessBlock)success failure:(FailureBlock)failure {
    if (retryCount >= kMaxRetryCount) {
        NSError *err = [NSError errorWithDomain:@"NetWorkManager" code:401 userInfo:@{ NSLocalizedDescriptionKey: @"登录已失效，请重新登录" }];
        [self forceLogoutAndFailWithError:err failure:failure];
        return;
    }
    __weak typeof(self) w = self;
    NLPendingAuthRequest *req = [[NLPendingAuthRequest alloc] init];
    req.path = path;
    req.params = params;
    req.isGET = isGET;
    req.success = success;
    req.failure = failure;
    dispatch_async(self.refreshLockQueue, ^{
        if (w.isRefreshing) {
            [w.pendingRequests addObject:req];
            return;
        }
        w.isRefreshing = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [NLAuthService refreshLoginWithSuccess:^{
                dispatch_async(w.refreshLockQueue, ^{
                    NSArray *pending = [w.pendingRequests copy];
                    [w.pendingRequests removeAllObjects];
                    w.isRefreshing = NO;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [w retryRequest:req withRetryCount:1];
                        for (NLPendingAuthRequest *p in pending) {
                            [w retryRequest:p withRetryCount:1];
                        }
                    });
                });
            } failure:^(NSError *refreshError) {
                dispatch_async(w.refreshLockQueue, ^{
                    NSArray *pending = [w.pendingRequests copy];
                    [w.pendingRequests removeAllObjects];
                    w.isRefreshing = NO;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (failure) failure(refreshError);
                        for (NLPendingAuthRequest *p in pending) {
                            if (p.failure) p.failure(refreshError);
                        }
                        [w forceLogoutAndKickToLogin];
                    });
                });
            }];
        });
    });
}

- (void)retryRequest:(NLPendingAuthRequest *)req withRetryCount:(NSInteger)retryCount {
    if (req.isGET) {
        [self GET:req.path parameters:req.params retryCount:retryCount success:req.success failure:req.failure];
    } else {
        [self POST:req.path parameters:req.params retryCount:retryCount success:req.success failure:req.failure];
    }
}

@end
