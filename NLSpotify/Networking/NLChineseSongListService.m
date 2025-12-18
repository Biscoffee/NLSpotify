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

    NSString *path = @"/top/playlist/highquality";
    NSDictionary *params = @{
        @"limit": @(limit),
        @"cat":@"华语"
    };
    [[NetWorkManager sharedManager] GET:path
                             parameters:params
                                success:^(id responseObject) {

      NSLog(@"CHĦ%@", responseObject);
        NSArray *result = responseObject[@"playlists"];
     // NSMutableArray *resultArray = [NSMutableArray array];
      NSLog(@"chiiiiiiiiiii%@", result);
//      for (NSDictionary *albumDict in result) {
//        NLRecommendAlbumListModel *model = [[NLRecommendAlbumListModel alloc] init];
//        model.picUrl = albumDict[@"coverImgUrl"];
//        model.name = albumDict[@"name"];
//        [resultArray addObject:model];
//      }
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
