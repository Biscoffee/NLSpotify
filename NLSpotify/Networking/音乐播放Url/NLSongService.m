//
//  NLSongService.m
//  NLSpotify
//
//  Created by 吴桐 on 2026/1/19.
//

#import "NLSongService.h"

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

    NSDictionary *params = @{@"id": songId};

    [[NetWorkManager sharedManager] GET:@"/song/url" parameters:params success:^(id  _Nonnull responseObject) {

        NSString *playURLString = nil;
        NSArray *dataArray = responseObject[@"data"];
        if (dataArray.count > 0) {
            playURLString = dataArray[0][@"url"];
        }

        if (!playURLString || [playURLString containsString:@"403"]) {
            playURLString = [NSString stringWithFormat:
                             @"https://music.163.com/song/media/outer/url?id=%@.mp3", songId];
        }

        NSURL *playURL = [NSURL URLWithString:playURLString];
        if (success) {
            success(playURL);
        }
    } failure:^(NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}

@end
