//
//  NLSongListServiece.h
//  NLSpotify
//
//  Created by 吴桐 on 2026/1/8.
//

#import <Foundation/Foundation.h>
#import "NLHeaderModel.h"

NS_ASSUME_NONNULL_BEGIN

@class NLListCellModel;

@interface NLSongListServiece : NSObject

+ (void)fetchPlayListDetailWithId:(NSInteger)playlistId
                       completion:(void (^)(NLHeaderModel *playlist,NSArray<NLListCellModel *> *songs))completion;

@end

NS_ASSUME_NONNULL_END
