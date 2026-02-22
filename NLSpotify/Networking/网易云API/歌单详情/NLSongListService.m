//
//  NLSongListService.m
//  NLSpotify
//
//  Created by 吴桐 on 2026/1/8.
//

#import "NLSongListService.h"
#import "NLListCellModel.h"
#import "NLHeaderModel.h"
#import "NetWorkManager.h"

@implementation NLSongListService

+ (void)fetchPlayListDetailWithId:(NSInteger)playlistId
                       completion:(void (^)(NLHeaderModel *,
                                            NSArray<NLListCellModel *> *))completion {
    if (playlistId <= 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(nil, @[]);
        });
        return;
    }

    NSDictionary *params = @{ @"id": @(playlistId), @"offset": @0 };
    [[NetWorkManager sharedManager] GET:@"/playlist/detail"
                            parameters:params
                               success:^(id _Nullable responseObject) {
        if (![responseObject isKindOfClass:[NSDictionary class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(nil, @[]);
            });
            return;
        }
        NSDictionary *json = (NSDictionary *)responseObject;
        NSInteger code = [json[@"code"] integerValue];
        if (code != 200) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(nil, @[]);
            });
            return;
        }
        NSDictionary *playlistDict = json[@"playlist"];
        if (![playlistDict isKindOfClass:[NSDictionary class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(nil, @[]);
            });
            return;
        }

        NLHeaderModel *playlist = [[NLHeaderModel alloc] init];
        playlist.playlistId = [playlistDict[@"id"] integerValue];
        playlist.name = playlistDict[@"name"];
        playlist.coverUrl = playlistDict[@"coverImgUrl"];
        playlist.desc = playlistDict[@"description"] ?: @"";

        NSDictionary *creator = playlistDict[@"creator"];
        if ([creator isKindOfClass:[NSDictionary class]]) {
            playlist.creatorName = creator[@"nickname"];
            playlist.creatorAvatar = creator[@"avatarUrl"];
        }

        NSMutableArray *songs = [NSMutableArray array];
        NSArray *tracks = playlistDict[@"tracks"];
        if ([tracks isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dict in tracks) {
                NLListCellModel *song = [[NLListCellModel alloc] init];
                song.songId = [dict[@"id"] integerValue];
                song.name = dict[@"name"];
                song.duration = [dict[@"dt"] integerValue];
                NSArray *artists = dict[@"ar"];
                if ([artists isKindOfClass:[NSArray class]] && artists.count > 0) {
                    song.artistName = artists.firstObject[@"name"];
                }
                NSDictionary *album = dict[@"al"];
                if ([album isKindOfClass:[NSDictionary class]]) {
                    song.albumName = album[@"name"];
                    song.coverUrl = album[@"picUrl"];
                }
                [songs addObject:song];
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(playlist, [songs copy]);
        });
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(nil, @[]);
        });
    }];
}

@end
