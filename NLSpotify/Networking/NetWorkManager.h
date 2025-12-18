//
//  NetWorkManager.h
//  NLSpotify
//
//  Created by 吴桐 on 2025/12/15.
//

#import <Foundation/Foundation.h>
#import "AFNetworking/AFNetworking.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, NLRequestMethod) {
  NLRequestMethodGET,
  NLRequestMethodPOST
};

typedef void(^SuccessBlock)(id _Nullable responseObject);
typedef void(^FailureBlock)(NSError *error);

@interface NetWorkManager : NSObject

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
+(id)sharedManager;
- (void)GET:(NSString *)url
 parameters:(NSDictionary *)params
    success:(SuccessBlock)success
    failure:(FailureBlock)failure;

- (void)POST:(NSString *)url
  parameters:(NSDictionary *)params
     success:(SuccessBlock)success
     failure:(FailureBlock)failure;

@end

NS_ASSUME_NONNULL_END
