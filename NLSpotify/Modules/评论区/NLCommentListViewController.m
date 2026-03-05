//
//  NLCommentListViewController.m
//  NLSpotify
//

#import "NLCommentListViewController.h"
#import "NLCommentService.h"
#import "NLCommentModel.h"
#import "NLCommentCell.h"
#import <Masonry/Masonry.h>

static const NSInteger kPageSize = 20;

@interface NLCommentListViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, assign) NSInteger resourceId;
@property (nonatomic, assign) NLCommentResourceType resourceType;
@property (nonatomic, copy) NSString *pageTitle;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<NLCommentModel *> *comments;
@property (nonatomic, assign) NSInteger total;
@property (nonatomic, assign) NSInteger currentOffset;

@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL hasLoadedOnce; // 至少成功加载过一回，用于区分「未加载」和「已加载完」
@end

@implementation NLCommentListViewController

- (instancetype)initWithResourceId:(NSInteger)resourceId
                     resourceType:(NLCommentListResourceType)type
                            title:(NSString *)title {
    self = [super init];
    if (self) {
        _resourceId = resourceId;
        _resourceType = (NLCommentResourceType)type;
        _pageTitle = title ?: @"评论";
        _comments = [NSMutableArray array];
        _currentOffset = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.title = self.pageTitle;

    [self.view addSubview:self.tableView];
    [self setupConstraints];
    [self loadData];
}

- (void)setupConstraints {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)loadData {
    if (self.isLoading) return;
    self.isLoading = YES;
    [self updateLoadingFooter:YES];
    __weak typeof(self) w = self;
    [NLCommentService fetchCommentsWithResourceId:self.resourceId
                                    resourceType:self.resourceType
                                           limit:kPageSize
                                          offset:self.currentOffset
                                          before:nil
                                         success:^(NSArray<NLCommentModel *> *comments, NSInteger total) {
        w.isLoading = NO;
        w.hasLoadedOnce = YES;
        w.total = total;
        if (w.currentOffset == 0) {
            [w.comments removeAllObjects];
        }
        [w.comments addObjectsFromArray:comments];
        [w.tableView reloadData];
        [w updateLoadingFooter:NO];
    } failure:^(NSError *error) {
        w.isLoading = NO;
        [w updateLoadingFooter:NO];
        NSLog(@"评论加载失败: %@", error.localizedDescription);
    }];
}

- (void)updateLoadingFooter:(BOOL)loading {
    CGFloat width = CGRectGetWidth(self.view.bounds);
    if (loading && self.comments.count < self.total) {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 44)];
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        indicator.translatesAutoresizingMaskIntoConstraints = NO;
        [footerView addSubview:indicator];
        [indicator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(footerView);
        }];
        [indicator startAnimating];
        self.tableView.tableFooterView = footerView;
    } else if (self.hasLoadedOnce && self.comments.count >= self.total && self.total >= 0) {
        // 已经加载过且没有更多了，显示「没有更多评论」
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 44)];
        UILabel *label = [[UILabel alloc] init];
        label.text = @"没有更多评论";
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor tertiaryLabelColor];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        [footerView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(footerView);
        }];
        self.tableView.tableFooterView = footerView;
    } else {
        self.tableView.tableFooterView = [UIView new];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NLCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell" forIndexPath:indexPath];
    cell.comment = self.comments[indexPath.row];
    __weak typeof(tableView) weakTable = tableView;
/*
 在这个block中，如果我们使用reload方法，那么实际上tableview会直接把这个cell暴力扔进复用池，重新调用cellForRow。
 而 beginUpdates / endUpdates 的中间什么都不写时，会强制出发高度重算，而非全部重置，因此优化效果还是较为客观的。
 然后这个performWithoutAnimation也还是有用的，由于屏蔽了动画，cell会迅速变化，否则会有一个非常诡异的拉伸效果
 */
    cell.expandBlock = ^{
//        [tableView reloadRowsAtIndexPaths:@[indexPath]
//                                 withRowAnimation:UITableViewRowAnimationNone];
        __strong typeof(weakTable) table = weakTable;
        if (!table) return;
        [UIView performWithoutAnimation:^{
            [table beginUpdates];
            [table endUpdates];
        }];
    };
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NLCommentModel *comment = self.comments[indexPath.row];
    CGFloat cachedHeight = comment.isExpanded ? comment.expandedHeight : comment.collapsedHeight;
    if (cachedHeight > 0) {
        return cachedHeight;
    }
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.comments.count - 3 && self.comments.count < self.total && !self.isLoading) {
        self.currentOffset = self.comments.count;
        [self loadData];
    }

    // 首次展示时记录实际高度，后续直接使用缓存
    if (indexPath.row < self.comments.count) {
        NLCommentModel *comment = self.comments[indexPath.row];
        CGFloat height = CGRectGetHeight(cell.bounds);
        if (comment.isExpanded) {
            comment.expandedHeight = height;
        } else {
            comment.collapsedHeight = height;
        }
    }
}


/*

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.isLoading || self.comments.count >= self.total || self.comments.count == 0) return;
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat contentH = scrollView.contentSize.height;
    CGFloat visibleH = scrollView.bounds.size.height;
    // 当前滚动位置 + 可见高度 > 内容高度 - 阈值 时，认为接近底部
    if (offsetY + visibleH > contentH - 80) {
        self.currentOffset = self.comments.count;
        [self loadData];
    }
}

*/
#pragma mark - Getters

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollEnabled = YES;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorInset = UIEdgeInsetsMake(0, 56, 0, 0);
        _tableView.tableFooterView = [UIView new];
        [_tableView registerClass:[NLCommentCell class] forCellReuseIdentifier:@"CommentCell"];
    }
    return _tableView;
}


@end
