//
//  NLAlbumService.m
//  NLSpotify
//
//  Created by 吴桐 on 2026/1/14.
//

#import "NLAlbumService.h"
#import "NetWorkManager.h"
#import "NLHeaderModel.h"
#import "NLListCellModel.h"

@implementation NLAlbumService

+ (void)fetchAlbumDetailWithId:(NSInteger)albumId
                    completion:(void (^)(NLHeaderModel *header,
                                         NSArray<NLListCellModel *> *songs))completion {
    if (albumId <= 0) {
        if (completion) completion(nil, @[]);
        return;
    }
    [[NetWorkManager sharedManager] GET:@"/album" parameters:@{ @"id": @(albumId) } success:^(id responseObject) {

        NSDictionary *json = (NSDictionary *)responseObject;
        NSDictionary *albumDict = json[@"album"];
        if (![albumDict isKindOfClass:[NSDictionary class]]) {
            if (completion) completion(nil, @[]);
            return;
        }

        NLHeaderModel *header = [[NLHeaderModel alloc] init];
        header.playlistId = [albumDict[@"id"] integerValue];
        header.name = albumDict[@"name"];
        header.coverUrl = albumDict[@"picUrl"];
        header.desc = albumDict[@"description"] ?: @"";

        NSDictionary *artistDict = albumDict[@"artist"];
        if ([artistDict isKindOfClass:[NSDictionary class]]) {
            header.creatorName = artistDict[@"name"];
            header.creatorAvatar = artistDict[@"img1v1Url"];
        }
      // NSLog(@"artistdict: %@",artistDict); // 专注播放器时先注释

        // =========================
        // 2️⃣ Songs（歌曲列表）
        // =========================
        NSMutableArray<NLListCellModel *> *songs = [NSMutableArray array];
        NSArray *songArray = json[@"songs"];

        for (NSDictionary *dict in songArray) {

            NLListCellModel *song = [[NLListCellModel alloc] init];
            song.songId = [dict[@"id"] integerValue];
            song.name = dict[@"name"];
            song.duration = [dict[@"dt"] integerValue];

            // 歌手
            NSArray *artists = dict[@"ar"];
            if ([artists isKindOfClass:[NSArray class]] && artists.count > 0) {
                song.artistName = artists.firstObject[@"name"];
            }

            // 专辑
            NSDictionary *album = dict[@"al"];
            if ([album isKindOfClass:[NSDictionary class]]) {
                song.albumName = album[@"name"];
                song.coverUrl = album[@"picUrl"];
            }

            [songs addObject:song];
        }

      // NSLog(@"songs: %@",songs); // 专注播放器时先注释
          if (completion) {
            completion(header, songs);
        }

    } failure:^(NSError *error) {
        NSLog(@"Album 请求失败: %@", error);
        if (completion) completion(nil, @[]);
    }];
}

@end
