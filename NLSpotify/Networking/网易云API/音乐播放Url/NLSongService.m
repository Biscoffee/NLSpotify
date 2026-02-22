//
//  NLSongService.m
//  NLSpotify
//
//  Created by 吴桐 on 2026/1/19.
//

#import "NLSongService.h"

static NSString *firstSongIdFromString(NSString *ids) {
    NSArray *parts = [ids componentsSeparatedByString:@","];
    NSString *first = [parts.firstObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return first.length > 0 ? first : ids;
}

@implementation NLSongService

+ (instancetype)sharedService {
    static NLSongService *service;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[NLSongService alloc] init];
    });
    return service;
}

- (void)fetchPlayableURLWithSongId:(NSString *)songId
                           success:(SongURLFetchSuccess)success
                           failure:(SongFetchFailure)failure {
    if (!songId || songId.length == 0) {
        NSLog(@"[NLSongService] 歌曲 ID 为空");
        if (failure) failure([NSError errorWithDomain:@"NLSongService" code:400 userInfo:@{NSLocalizedDescriptionKey: @"歌曲 ID 为空"}]);
        return;
    }
    NSLog(@"[NLSongService] 开始获取播放链接 songId=%@", songId);
    NSDictionary *params = @{@"id": songId};

    [[NetWorkManager sharedManager] GET:@"/song/url" parameters:params success:^(id _Nonnull responseObject) {
        NSString *playURLString = nil;
        NSString *resolvedId = firstSongIdFromString(songId);
        NSArray *dataArray = responseObject[@"data"];

        if ([dataArray isKindOfClass:[NSArray class]] && dataArray.count > 0) {
            id item = dataArray[0];
            if ([item isKindOfClass:[NSDictionary class]]) {
                id urlObj = item[@"url"];
                if ([urlObj isKindOfClass:[NSString class]]) {
                    playURLString = (NSString *)urlObj;
                }
            }
        }

        if (playURLString.length == 0 || [playURLString containsString:@"403"]) {
            playURLString = [NSString stringWithFormat:@"https://music.163.com/song/media/outer/url?id=%@.mp3", resolvedId];
            NSLog(@"[NLSongService] 接口返回空或 403，使用外链兜底 url=%@", playURLString);
        } else {
            NSLog(@"[NLSongService] 获取成功 url=%@", playURLString);
        }

        NSURL *playURL = [NSURL URLWithString:playURLString];
        if (success) success(playURL);
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"[NLSongService] 请求失败 songId=%@ error=%@", songId, error);
        if (failure) failure(error);
    }];
}

@end
