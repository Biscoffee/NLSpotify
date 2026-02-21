//
//  NLCommentModel.m
//  NLSpotify
//

#import "NLCommentModel.h"

@implementation NLCommentUserModel
@end

@implementation NLCommentModel

+ (nullable instancetype)modelWithDictionary:(NSDictionary *)dict {
    if (![dict isKindOfClass:[NSDictionary class]]) return nil;
    NLCommentModel *m = [[NLCommentModel alloc] init];
    m.commentId = [dict[@"commentId"] integerValue];
    if (m.commentId == 0) m.commentId = [dict[@"id"] integerValue];
    m.content = [dict[@"content"] description] ?: @"";
    m.time = [dict[@"time"] doubleValue] / 1000.0;
    m.likedCount = [dict[@"likedCount"] integerValue];
    m.replyCount = [dict[@"replyCount"] integerValue];

    NSDictionary *userDict = dict[@"user"];
    if ([userDict isKindOfClass:[NSDictionary class]]) {
        NLCommentUserModel *u = [[NLCommentUserModel alloc] init];
        u.nickname = [userDict[@"nickname"] description] ?: @"";
        u.avatarUrl = [userDict[@"avatarUrl"] description] ?: @"";
        u.userId = [userDict[@"userId"] integerValue];
        m.user = u;
    }

    NSArray *beReplied = dict[@"beReplied"];
    if ([beReplied isKindOfClass:[NSArray class]]) {
        NSMutableArray *replies = [NSMutableArray array];
        for (NSDictionary *r in beReplied) {
            NLCommentModel *reply = [NLCommentModel modelWithDictionary:r];
            if (reply) [replies addObject:reply];
        }
        m.beReplied = [replies copy];
    }
    return m;
}

@end
