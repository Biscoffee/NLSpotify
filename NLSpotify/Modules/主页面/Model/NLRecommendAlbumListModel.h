//
//  NLPlayListModel.h
//  NLSpotify
//
//  Created by 吴桐 on 2025/12/14.
//
//歌单模型
#import <Foundation/Foundation.h>
#import "YYModel/YYModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NLRecommendAlbumListModel : NSObject

@property (nonatomic, assign) NSInteger playlistId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *picUrl;
@property (nonatomic, assign) NSInteger playCount;
@property (nonatomic, assign) NSInteger trackCount;



@end

NS_ASSUME_NONNULL_END
