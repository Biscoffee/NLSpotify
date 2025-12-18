//
//  NLPlayListService.m
//  NLSpotify
//
//  Created by 吴桐 on 2025/12/16.
//

#import "NLRecommendAlbumListService.h"
#import "NetWorkManager.h"
#import "NLRecommendAlbumListModel.h"

@implementation NLRecommendAlbumListService

+ (instancetype)sharedService {
    static NLRecommendAlbumListService *service;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[NLRecommendAlbumListService alloc] init];
    });
    return service;
}

- (void)fetchRecommendPlayListWithLimit:(NSInteger)limit
                                 success:(void (^)(NSArray<NLRecommendAlbumListModel *> *))success
                                 failure:(void (^)(NSError *))failure {

    NSString *path = @"/personalized";
    NSDictionary *params = @{
        @"limit": @(limit)
    };

    [[NetWorkManager sharedManager] GET:path
                             parameters:params
                                success:^(id responseObject) {

        NSArray *result = responseObject[@"result"];
     // NSLog(@"%@", result);
        NSArray *models =
        [NSArray yy_modelArrayWithClass:NLRecommendAlbumListModel.class json:result];

        if (success) {
            success(models);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

@end
