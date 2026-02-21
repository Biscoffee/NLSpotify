//
//  NLCommentCell.h
//  NLSpotify
//

#import <UIKit/UIKit.h>

@class NLCommentModel;

NS_ASSUME_NONNULL_BEGIN

@interface NLCommentCell : UITableViewCell
@property (nonatomic, strong) NLCommentModel *comment;
@property (nonatomic, copy, nullable) void (^expandBlock)(void);
@end

NS_ASSUME_NONNULL_END
