//
//  NLPlayListViewController.h
//  NLSpotify
//
//  Created by 吴桐 on 2026/1/17.
//

#import <UIKit/UIKit.h>
#import "NLCategoryModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface NLPlaylistViewController : UIViewController

@property (nonatomic, copy) NSString *categoryName;
@property (nonatomic, copy) NSString *categoryId;
@property (nonatomic, strong) NLCategoryModel *categoryModel;

- (instancetype)initWithCategoryModel:(NLCategoryModel *)model;

@end

NS_ASSUME_NONNULL_END
