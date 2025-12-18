//
//  NLPlayListModel.m
//  NLSpotify
//
//  Created by 吴桐 on 2025/12/14.
//

#import "NLRecommendAlbumListModel.h"

@implementation NLRecommendAlbumListModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"playlistId": @"id",
        @"picUrl": @[@"picUrl", @"coverImgUrl"]
    };
}

@end
