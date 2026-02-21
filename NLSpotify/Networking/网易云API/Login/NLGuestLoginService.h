//
//  NLGuestLoginService.h
//  NLSpotify
//
//  Created by 吴桐 on 2026/1/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NLGuestLoginService : NSObject

+ (void)anonymousLoginWithSuccess:(void(^)(NSDictionary *response))success
                          failure:(void(^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
