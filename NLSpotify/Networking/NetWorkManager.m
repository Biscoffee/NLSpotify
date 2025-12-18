//
//  NetWorkManager.m
//  NLSpotify
//
//  Created by 吴桐 on 2025/12/15.
//

#import "NetWorkManager.h"

static NSString * const kBaseURL = @"https://1390963969-2g6ivueiij.ap-guangzhou.tencentscf.com";

@implementation NetWorkManager


+ (id) sharedManager {
  static NetWorkManager *manager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    manager = [[NetWorkManager alloc] init];
  });
  return manager;
}

- (AFHTTPSessionManager *)sessionManager {
  AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
  manager.requestSerializer = [AFJSONRequestSerializer serializer];
  manager.responseSerializer = [AFJSONResponseSerializer serializer];
  manager.requestSerializer.timeoutInterval = 20;
  return manager;
}

- (void)GET:(NSString *)path parameters:(NSDictionary *)params success:(SuccessBlock)success failure:(FailureBlock)failure {
  NSString *url = [kBaseURL stringByAppendingString:path];
  [[self sessionManager] GET:url parameters:params headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    if (success) success(responseObject);
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    if (failure) failure(error);
  }];
}

-(void) POST:(NSString *)url parameters:(NSDictionary *)params success:(SuccessBlock)success failure:(FailureBlock)failure {
  [[self sessionManager] POST:url parameters:params headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    if (success) success(responseObject);
      } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if(failure) failure(error);
      }];
}

@end
