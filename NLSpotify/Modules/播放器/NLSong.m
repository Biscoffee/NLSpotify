//
//  NLSong.m
//  NLSpotify
//
//  Created by 吴桐 on 2026/1/18.
//

#import "NLSong.h"
#import "NLListCellModel.h"

@implementation NLSong

- (instancetype)initWithId:(NSString *)songId
                     title:(NSString *)title
                    artist:(NSString *)artist
                  coverURL:(NSURL *)coverURL {

    if (self = [super init]) {
        _songId = songId;
        _title = title;
        _artist = artist;
        _coverURL = coverURL;
    }
    return self;
}

+ (instancetype)songWithListCellModel:(NLListCellModel *)model {
    if (!model) return nil;

    NSURL *coverURL = nil;
    if (model.coverUrl.length > 0) {
        NSString *urlString = model.coverUrl;

        // http -> https
        if ([urlString hasPrefix:@"http://"]) {
            urlString = [urlString stringByReplacingOccurrencesOfString:@"http://"
                                                             withString:@"https://"];
        }

        coverURL = [NSURL URLWithString:urlString];
    }

    return [[NLSong alloc] initWithId:[NSString stringWithFormat:@"%ld", (long)model.songId]
                                 title:model.name ?: @""
                                artist:model.artistName ?: @""
                              coverURL:coverURL];
}

@end
