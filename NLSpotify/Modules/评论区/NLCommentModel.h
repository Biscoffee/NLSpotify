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

// 文本缓存、
@property (nonatomic, copy, nullable) NSAttributedString *collapsedAttr;
@property (nonatomic, copy, nullable) NSAttributedString *expandedAttr;
@property (nonatomic, copy, nullable) NSAttributedString *displayText;

// 高度缓存
@property (nonatomic, assign) CGFloat collapsedHeight;
@property (nonatomic, assign) CGFloat expandedHeight;

@property (nonatomic, assign) NSInteger replyCount;
@property (nonatomic, copy) NSArray<NLCommentModel *> *beReplied;


+ (nullable instancetype)modelWithDictionary:(NSDictionary *)dict;
@end

NS_ASSUME_NONNULL_END
