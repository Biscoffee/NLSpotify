//
//  NLAlbumService.h
//  NLSpotify
//
//  Created by 吴桐 on 2026/1/14.
//

#import <Foundation/Foundation.h>
#import "NLHeaderModel.h"
#import "NLListCellModel.h"
#import "NetWorkManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface NLAlbumService : NSObject
+ (void)fetchAlbumDetailWithId:(NSInteger)albumId
                    completion:(void (^)(NLHeaderModel *header,
                                         NSArray<NLListCellModel *> *songs))completion;

@end

NS_ASSUME_NONNULL_END
