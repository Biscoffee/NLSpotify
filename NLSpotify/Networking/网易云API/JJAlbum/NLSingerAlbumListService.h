//
//  NLSingerListService.h
//  NLSpotify
//
//  Created by 吴桐 on 2025/12/16.
//

#import <Foundation/Foundation.h>
#import "NLSingerAlbumListModel.h"
#import "YYModel/YYModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NLSingerAlbumListService : NSObject
+ (instancetype)sharedService;

- (void)fetchSingerListWithSuccess:(void (^)(NSArray<NLSingerAlbumListModel *> *singers))success
                            failure:(void (^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
