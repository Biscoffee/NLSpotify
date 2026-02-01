//
//  NLPlayListModel.m
//  NLSpotify
//
//  Created by 吴桐 on 2026/1/17.
//

#import "NLPlaylistModel.h"

@implementation NLPlaylistModel

+ (instancetype)playlistWithDictionary:(NSDictionary *)dict {
    NLPlaylistModel *model = [[self alloc] init];

  model.playlistId = [dict[@"id"] integerValue];\
    model.name = dict[@"name"] ?: @"";
    model.coverImgUrl = dict[@"coverImgUrl"] ?: @"";
    model.descriptionText = dict[@"description"] ?: @"";
    model.playCount = [dict[@"playCount"] integerValue];
    model.subscribedCount = [dict[@"subscribedCount"] integerValue];
    model.trackCount = [dict[@"trackCount"] integerValue];

    // 创建者信息
    NSDictionary *creator = dict[@"creator"];
    if (creator) {
        model.creatorName = creator[@"nickname"] ?: @"";
        model.creatorAvatarUrl = creator[@"avatarUrl"] ?: @"";
    }

    // 标签
    NSArray *tags = dict[@"tags"];
    if ([tags isKindOfClass:[NSArray class]]) {
        model.tags = tags;
    } else {
        model.tags = @[];
    }

    return model;
}

@end
