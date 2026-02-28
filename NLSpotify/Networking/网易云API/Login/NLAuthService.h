//
//  NLAuthService.h
//  NLSpotify
//
//  Created by 吴桐 on 2026/2/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NLAuthService : NSObject
+ (void)refreshLoginWithSuccess:(void(^)(void))success
                        failure:(void(^)(NSError *error))failure;
@end

NS_ASSUME_NONNULL_END
