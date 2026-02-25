//
//  NLCreatePlayListSheetViewController.h
//  NLSpotify
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^NLCreatePlayListCompletion)(NSString *name);

@interface NLCreatePlayListSheetViewController : UIViewController

@property (nonatomic, copy, nullable) NLCreatePlayListCompletion completion;
@property (nonatomic, copy) NSString *titleText;
@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, copy) NSString *confirmButtonTitle;

@end

NS_ASSUME_NONNULL_END

