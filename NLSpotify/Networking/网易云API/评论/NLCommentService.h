//
//  NLCommentService.h
//  NLSpotify
//

#import <Foundation/Foundation.h>

@class NLCommentModel;

NS_ASSUME_NONNULL_BEGIN

// 资源类型：0 歌曲 1 mv 2 歌单 3 专辑 4 电台节目 5 视频 6 动态 7 电台
typedef NS_ENUM(NSInteger, NLCommentResourceType) {
    NLCommentResourceTypeSong = 0,
    NLCommentResourceTypeMV = 1,
    NLCommentResourceTypePlaylist = 2,
    NLCommentResourceTypeAlbum = 3,
    NLCommentResourceTypeRadio = 4,
    NLCommentResourceTypeVideo = 5,
    NLCommentResourceTypeEvent = 6,
    NLCommentResourceTypeRadioProgram = 7,
};

@interface NLCommentService : NSObject

// 歌曲/专辑/歌单评论（主评论列表）
+ (void)fetchCommentsWithResourceId:(NSInteger)resourceId
                        resourceType:(NLCommentResourceType)type
                               limit:(NSInteger)limit
                              offset:(NSInteger)offset
                              before:(nullable NSNumber *)before
                             success:(void(^)(NSArray<NLCommentModel *> *comments, NSInteger total))success
                             failure:(void(^)(NSError *error))failure;

// 楼层回复
+ (void)fetchFloorCommentsWithParentCommentId:(NSInteger)parentCommentId
                                    resourceId:(NSInteger)resourceId
                                  resourceType:(NLCommentResourceType)type
                                         limit:(NSInteger)limit
                                          time:(nullable NSNumber *)time
                                       success:(void(^)(NSArray<NLCommentModel *> *comments))success
                                       failure:(void(^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
