//
//  NLChineseSongListService.h
//  NLSpotify
//
//  Created by 吴桐 on 2025/12/18.
//

#import <Foundation/Foundation.h>
#import "NLRecommendAlbumListModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NLChineseSongListService : NSObject

+ (id)sharedService;

- (void)fetchRecommendPlayListWithLimit:(NSInteger)limit
                                 success:(void(^)(NSArray<NLRecommendAlbumListModel *> *list))success
                                 failure:(void(^)(NSError *error))failure;

/// 获取精品歌单，cat 如 "华语"、"欧美"、"流行" 等，传 nil 或 @"" 为全部
- (void)fetchHighQualityPlaylistsWithCategory:(NSString *)category
                                       limit:(NSInteger)limit
                                     success:(void(^)(NSArray<NLRecommendAlbumListModel *> *list))success
                                     failure:(void(^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
