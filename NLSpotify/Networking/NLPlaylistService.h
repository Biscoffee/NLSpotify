//
//  NLPlaylsitServiece.h
//  NLSpotify
//
//  Created by 吴桐 on 2026/1/17.
//

#import <Foundation/Foundation.h>
#import "NLPlaylistModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NLPlaylistService : NSObject

+ (void)fetchPlaylistsWithCategory:(NSString *)category
                           success:(void(^)(NSArray<NLPlaylistModel *> *playlists))success
                           failure:(void(^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
