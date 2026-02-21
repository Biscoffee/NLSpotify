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

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.navigationItem.hidesBackButton = YES;
    self.definesPresentationContext = YES;
    self.navigationItem.searchController = self.searchController;
    self.navigationItem.hidesSearchBarWhenScrolling = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.searchController.searchBar becomeFirstResponder];
    });
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
    NSLog(@"正在搜索: %@", searchText);
}

#pragma mark - Getters

- (UISearchController *)searchController {
    if (!_searchController) {
        UISearchController *sc = [[UISearchController alloc] initWithSearchResultsController:nil];
        sc.searchResultsUpdater = self;
        sc.obscuresBackgroundDuringPresentation = NO;
        sc.hidesNavigationBarDuringPresentation = NO;
        sc.searchBar.delegate = self;
        sc.searchBar.placeholder = @"艺人、歌曲、歌词以及更多内容";
        sc.searchBar.searchBarStyle = UISearchBarStyleMinimal;
        sc.searchBar.showsCancelButton = YES;
        _searchController = sc;
    }
    return _searchController;
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

