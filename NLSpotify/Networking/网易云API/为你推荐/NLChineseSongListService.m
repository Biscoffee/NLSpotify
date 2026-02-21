//
//  NLChineseSongListService.m
//  NLSpotify
//
//  Created by 吴桐 on 2025/12/18.
//
#import "NetWorkManager.h"
#import "NLChineseSongListService.h"
#import "NLRecommendAlbumListModel.h"
#import "YYModel/YYModel.h"

@implementation NLChineseSongListService


+ (instancetype)sharedService {
    static NLChineseSongListService *service;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[NLChineseSongListService alloc] init];
    });
    return service;
}

- (void)fetchRecommendPlayListWithLimit:(NSInteger)limit
                                 success:(void (^)(NSArray<NLRecommendAlbumListModel *> *))success
                                 failure:(void (^)(NSError *))failure {
    [self fetchHighQualityPlaylistsWithCategory:@"华语" limit:limit success:success failure:failure];
}

- (void)fetchHighQualityPlaylistsWithCategory:(NSString *)category
                                       limit:(NSInteger)limit
                                     success:(void (^)(NSArray<NLRecommendAlbumListModel *> *))success
                                     failure:(void (^)(NSError *))failure {
    NSString *path = @"/top/playlist/highquality";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:@(limit) forKey:@"limit"];
    if (category.length > 0) {
        params[@"cat"] = category;
    }
    [[NetWorkManager sharedManager] GET:path
                             parameters:params
                                success:^(id responseObject) {
        NSArray *result = responseObject[@"playlists"];
        NSArray *resultArray = [NSArray yy_modelArrayWithClass:NLRecommendAlbumListModel.class json:result];
        if (success) {
            success(resultArray);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

@end
