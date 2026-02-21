//
//  NLCommentService.m
//  NLSpotify
//

#import "NLCommentService.h"
#import "NLCommentModel.h"
#import "NetWorkManager.h"

@implementation NLCommentService

+ (NSString *)pathForResourceType:(NLCommentResourceType)type {
    switch (type) {
        case NLCommentResourceTypeSong:   return @"/comment/music";
        case NLCommentResourceTypeAlbum:   return @"/comment/album";
        case NLCommentResourceTypePlaylist: return @"/comment/playlist";
        case NLCommentResourceTypeMV:     return @"/comment/music";
        default: return @"/comment/music";
    }
}

+ (void)fetchCommentsWithResourceId:(NSInteger)resourceId
                       resourceType:(NLCommentResourceType)type
                              limit:(NSInteger)limit
                             offset:(NSInteger)offset
                             before:(NSNumber *)before
                            success:(void (^)(NSArray<NLCommentModel *> * _Nonnull, NSInteger))success
                            failure:(void (^)(NSError * _Nonnull))failure {
    NSString *path = [self pathForResourceType:type];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"id"] = @(resourceId);
    params[@"limit"] = @(limit > 0 ? limit : 20);
    if (offset > 0) params[@"offset"] = @(offset);
    if (before != nil) params[@"before"] = before;

    [[NetWorkManager sharedManager] GET:path parameters:params success:^(id responseObject) {
        if (![responseObject isKindOfClass:[NSDictionary class]]) {
            if (failure) failure([NSError errorWithDomain:@"NLCommentService" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"返回格式错误"}]);
            return;
        }
        NSDictionary *json = (NSDictionary *)responseObject;
        NSInteger code = [json[@"code"] integerValue];
        if (code != 200) {
            if (failure) failure([NSError errorWithDomain:@"NLCommentService" code:code userInfo:@{NSLocalizedDescriptionKey: json[@"message"] ?: @"请求失败"}]);
            return;
        }
        NSInteger total = [json[@"total"] integerValue];
        NSArray *list = json[@"comments"];
        if (![list isKindOfClass:[NSArray class]]) list = @[];
        NSMutableArray *comments = [NSMutableArray array];
        for (NSDictionary *d in list) {
            NLCommentModel *m = [NLCommentModel modelWithDictionary:d];
            if (m) [comments addObject:m];
        }
        if (success) success([comments copy], total);
    } failure:^(NSError *error) {
        if (failure) failure(error);
    }];
}

+ (void)fetchFloorCommentsWithParentCommentId:(NSInteger)parentCommentId
                                   resourceId:(NSInteger)resourceId
                                 resourceType:(NLCommentResourceType)type
                                        limit:(NSInteger)limit
                                         time:(NSNumber *)time
                                      success:(void (^)(NSArray<NLCommentModel *> * _Nonnull))success
                                      failure:(void (^)(NSError * _Nonnull))failure {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"parentCommentId"] = @(parentCommentId);
    params[@"id"] = @(resourceId);
    params[@"type"] = @(type);
    params[@"limit"] = @(limit > 0 ? limit : 20);
    if (time != nil) params[@"time"] = time;

    [[NetWorkManager sharedManager] GET:@"/comment/floor" parameters:params success:^(id responseObject) {
        if (![responseObject isKindOfClass:[NSDictionary class]]) {
            if (failure) failure([NSError errorWithDomain:@"NLCommentService" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"返回格式错误"}]);
            return;
        }
        NSDictionary *json = (NSDictionary *)responseObject;
        NSInteger code = [json[@"code"] integerValue];
        if (code != 200) {
            if (failure) failure([NSError errorWithDomain:@"NLCommentService" code:code userInfo:@{NSLocalizedDescriptionKey: json[@"message"] ?: @"请求失败"}]);
            return;
        }
        NSArray *list = json[@"data"];
        if (![list isKindOfClass:[NSArray class]]) list = @[];
        NSMutableArray *comments = [NSMutableArray array];
        for (NSDictionary *d in list) {
            NLCommentModel *m = [NLCommentModel modelWithDictionary:d];
            if (m) [comments addObject:m];
        }
        if (success) success([comments copy]);
    } failure:^(NSError *error) {
        if (failure) failure(error);
    }];
}

@end
