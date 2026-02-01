//
//  NLSearchResultViewController.m
//  NLSpotify
//
//  Created by 吴桐 on 2026/1/21.
//

#import "NLSearchResultViewController.h"

@interface NLSearchResultViewController () <UISearchBarDelegate, UISearchResultsUpdating>
@property (nonatomic, strong) UISearchController *searchController;
@end

@implementation NLSearchResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.blackColor;
    self.navigationItem.hidesBackButton = YES;

    [self setupSearchController];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // 自动弹出键盘
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.searchController.searchBar becomeFirstResponder];
    });
}

- (void)setupSearchController {
    // 此时结果页是在自己身上展示，所以 initWithSearchResultsController 为 nil
    UISearchController *sc = [[UISearchController alloc] initWithSearchResultsController:nil];
    sc.searchResultsUpdater = self;
    sc.obscuresBackgroundDuringPresentation = NO;
    sc.hidesNavigationBarDuringPresentation = NO;

    sc.searchBar.delegate = self;
    sc.searchBar.placeholder = @"艺人、歌曲、歌词以及更多内容";
    sc.searchBar.searchBarStyle = UISearchBarStyleMinimal;

    // 关键：显示取消按钮（图2中的“X”）
    sc.searchBar.showsCancelButton = YES;

    // 自定义取消按钮样式（如果你想要更像 Apple Music 的叉号）
    // [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTitle:@"取消"];

    self.searchController = sc;
    self.navigationItem.searchController = sc;
    self.navigationItem.hidesSearchBarWhenScrolling = NO;

    // 解决推入页面时搜索框跳动的问题
    self.definesPresentationContext = YES;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    // 点击“取消”或“X”时，直接退回图1
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchText = searchController.searchBar.text;
    // 在这里执行具体的搜索逻辑
    NSLog(@"正在搜索: %@", searchText);
}

@end

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

