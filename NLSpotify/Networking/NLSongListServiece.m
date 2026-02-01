//
//  NLSongListServiece.m
//  NLSpotify
//
//  Created by 吴桐 on 2026/1/8.
//

#import "NLSongListServiece.h"
#import "NLListCellModel.h"

@implementation NLSongListServiece

+ (void)fetchPlayListDetailWithId:(NSInteger)playlistId
                       completion:(void (^)(NLHeaderModel *,
                                            NSArray<NLListCellModel *> *))completion {

    NSString *urlStr =
    [NSString stringWithFormat:
     @"https://1390963969-2g6ivueiij.ap-guangzhou.tencentscf.com/playlist/detail?id=%ld&offset=3",
     playlistId];

    NSURL *url = [NSURL URLWithString:urlStr];

    [[[NSURLSession sharedSession] dataTaskWithURL:url
                                 completionHandler:^(NSData *data,
                                                     NSURLResponse *response,
                                                     NSError *error) {

        if (!data || error) return;

        NSDictionary *json =
        [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

        NSDictionary *playlistDict = json[@"playlist"];
      //NSLog(@"SongListService:  %@", playlistDict);
        // ===== 歌单模型 =====
        NLHeaderModel *playlist = [[NLHeaderModel alloc] init];
        playlist.playlistId = [playlistDict[@"id"] integerValue];
        playlist.name = playlistDict[@"name"];
        playlist.coverUrl = playlistDict[@"coverImgUrl"];
        playlist.desc = playlistDict[@"description"];

        NSDictionary *creator = playlistDict[@"creator"];
        playlist.creatorName = creator[@"nickname"];
        playlist.creatorAvatar = creator[@"avatarUrl"];

        // ===== 歌曲列表 =====
        NSMutableArray *songs = [NSMutableArray array];
     // NSLog(@"%@", songs);
        for (NSDictionary *dict in playlistDict[@"tracks"]) {

            NLListCellModel *song = [[NLListCellModel alloc] init];
            song.songId = [dict[@"id"] integerValue];
            song.name = dict[@"name"];
            song.duration = [dict[@"dt"] integerValue];

            NSArray *artists = dict[@"ar"];
            if (artists.count > 0) {
                song.artistName = artists.firstObject[@"name"];
            }

            NSDictionary *album = dict[@"al"];
            song.albumName = album[@"name"];
            song.coverUrl = album[@"picUrl"];

            [songs addObject:song];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            completion(playlist, songs);
        });

    }] resume];
}

@end
