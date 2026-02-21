//
//  NLPlaylistService.m
//  NLSpotify
//
//  Created by 吴桐 on 2026/1/17.
//

#import "NLPlaylistService.h"
#import "NetWorkManager.h"

@implementation NLPlaylistService

+ (void)fetchPlaylistsWithCategory:(NSString *)category
                           success:(void(^)(NSArray<NLPlaylistModel *> *playlists))success
                           failure:(void(^)(NSError *error))failure {

    NSString *path = @"/top/playlist/highquality";

    NSMutableDictionary *params = [NSMutableDictionary dictionary];

    // 分类（可选，不传就是“全部”）
    if (category.length > 0) {
        params[@"cat"] = category;
    }

    // limit 固定 10
    params[@"limit"] = @10;

    // 👉 调试：打印请求
    //NSLog(@"🎧 请求精品歌单 params = %@", params);

    [[NetWorkManager sharedManager] GET:path
                             parameters:params
                                success:^(id responseObject) {

        if (![responseObject isKindOfClass:[NSDictionary class]]) {
            NSError *error = [NSError errorWithDomain:@"NLPlaylistServiceError"
                                                 code:-1
                                             userInfo:@{NSLocalizedDescriptionKey:@"返回数据格式错误"}];
            if (failure) failure(error);
            return;
        }

        NSDictionary *json = (NSDictionary *)responseObject;

        if ([json[@"code"] integerValue] != 200) {
            NSError *error =
            [NSError errorWithDomain:@"NLPlaylistServiceError"
                                code:[json[@"code"] integerValue]
                            userInfo:@{NSLocalizedDescriptionKey:
                                       json[@"message"] ?: @"请求失败"}];
            if (failure) failure(error);
            return;
        }

        NSArray *playlistsArray = json[@"playlists"];

        // 👉 调试：打印返回数量
//        NSLog(@"✅ 获取到精品歌单数量：%lu",
//              (unsigned long)playlistsArray.count);

        NSMutableArray *playlists = [NSMutableArray array];

        for (NSDictionary *dict in playlistsArray) {
            NLPlaylistModel *playlist =
            [NLPlaylistModel playlistWithDictionary:dict];
            if (playlist) {
                [playlists addObject:playlist];
            }
        }

        if (success) {
            success(playlists);
        }

    } failure:^(NSError *error) {
        NSLog(@"❌ 精品歌单请求失败：%@", error);
        if (failure) failure(error);
    }];
}

@end
