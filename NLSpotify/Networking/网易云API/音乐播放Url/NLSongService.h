//
//  NLSongService.h
//  NLSpotify
//
//  Created by 吴桐 on 2026/1/19.
//

#import <Foundation/Foundation.h>
#import "NLSong.h"
#import "NetWorkManager.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^SongURLFetchSuccess)(NSURL *playURL);
typedef void(^SongFetchFailure)(NSError *error);

@interface NLSongService : NSObject

+ (instancetype)sharedService;

- (void)fetchPlayableURLWithSongId:(NSString *)songId
                           success:(SongURLFetchSuccess)success
                           failure:(SongFetchFailure)failure;

@end

NS_ASSUME_NONNULL_END
