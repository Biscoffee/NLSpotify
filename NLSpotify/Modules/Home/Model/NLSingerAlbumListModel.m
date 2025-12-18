//
//  NLSingerListModel.m
//  NLSpotify
//
//  Created by 吴桐 on 2025/12/15.
//

#import "NLSingerAlbumListModel.h"
#import "YYModel/YYModel.h"

@implementation NLSingerAlbumListModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"singerId": @"id"};
}


@end
