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


@end

NS_ASSUME_NONNULL_END
