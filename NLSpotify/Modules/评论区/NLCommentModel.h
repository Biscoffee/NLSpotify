//
//  NLCommentModel.h
//  NLSpotify
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NLCommentUserModel : NSObject
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *avatarUrl;
@property (nonatomic, assign) NSInteger userId;
@end

@interface NLCommentModel : NSObject
@property (nonatomic, assign) NSInteger commentId;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) NSTimeInterval time;
@property (nonatomic, assign) NSInteger likedCount;
@property (nonatomic, strong) NLCommentUserModel *user;


@property (nonatomic, assign) BOOL isExpanded;
@property (nonatomic, assign) BOOL needExpand;
@property (nonatomic, copy) NSAttributedString *displayText;

/// 回复数量（主评论列表接口可能返回 replyCount）
@property (nonatomic, assign) NSInteger replyCount;
/// 部分回复（主评论里可能带几条）
@property (nonatomic, copy) NSArray<NLCommentModel *> *beReplied;


+ (nullable instancetype)modelWithDictionary:(NSDictionary *)dict;
@end

NS_ASSUME_NONNULL_END
