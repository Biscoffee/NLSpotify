//
//  NLPlayListService.h
//  NLSpotify
//
//  Created by 吴桐 on 2025/12/16.
//

#import <Foundation/Foundation.h>

@class NLRecommendAlbumListModel;

NS_ASSUME_NONNULL_BEGIN

@interface NLRecommendAlbumListService : NSObject

+ (id)sharedService;

- (void)fetchRecommendPlayListWithLimit:(NSInteger)limit
                                 success:(void(^)(NSArray<NLRecommendAlbumListModel *> *list))success
                                 failure:(void(^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
