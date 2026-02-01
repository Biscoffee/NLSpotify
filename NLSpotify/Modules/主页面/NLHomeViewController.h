//
//  NLHomeViewController.h
//  NLSpotify
//
//  Created by 吴桐 on 2025/12/13.
//

#import <UIKit/UIKit.h>
#import "NLHomeViewModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface NLHomeViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NLHomeViewModel *homeVM;
@end

NS_ASSUME_NONNULL_END
