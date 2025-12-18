//
//  NLHomeViewController.m
//  NLSpotify
//
//  Created by 吴桐 on 2025/12/13.
//

#import "NLHomeViewController.h"
#import "NLHomeViewModel.h"
#import "NLSectionViewModel.h"
#import "NLPlayListSmallCell.h"
#import "NLPlayListBigCell.h"
#import "Masonry/Masonry.h"

@implementation NLHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self loadData];
}

- (void)setupUI {
  self.view.backgroundColor = [UIColor blackColor];
  [self.navigationController setNavigationBarHidden:YES animated:NO];
  self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
  self.tableView.backgroundColor = [UIColor blackColor];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
//  self.tableView.rowHeight = UITableViewAutomaticDimension;
//  self.tableView.estimatedRowHeight = 200;
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  [self.view addSubview:self.tableView];

  [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
    make.left.right.bottom.equalTo(self.view);
  }];

  [self.tableView registerClass:NLPlayListSmallCell.class forCellReuseIdentifier:@"PlayListSmallCell"];
  [self.tableView registerClass:NLPlayListBigCell.class forCellReuseIdentifier:@"PlayListBigCell"];
}

- (void)loadData {
  self.homeVM = [[NLHomeViewModel alloc] init];
  [self.homeVM loadDataWithCompletion:^{
  [self.tableView reloadData];
  }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.homeVM numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NLSectionViewModel *sectionVM = [self.homeVM sectionAtIndex:indexPath.section];
  if (sectionVM.style == NLHomeSectionStylePlayListSmall) {
    NLPlayListSmallCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlayListSmallCell" forIndexPath:indexPath];
    [cell configWithSectionVM:sectionVM];
    __weak typeof(self) weakSelf = self;
        cell.didSelectPlayList = ^(NLRecommendAlbumListModel *model) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            [strongSelf handlePlayListSelected:model];
        };

    return cell;
  } else if (sectionVM.style == NLHomeSectionStylePlayListBig) {
    NLPlayListBigCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlayListBigCell" forIndexPath:indexPath];
    [cell configWithSectionVM:sectionVM];
    return cell;
  } else {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DefaultCell"];
    cell.textLabel.text = sectionVM.title;
    return cell;
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NLSectionViewModel *sectionVM = [self.homeVM sectionAtIndex:indexPath.section];
    switch (sectionVM.style) {
        case NLHomeSectionStylePlayListSmall:
            return 217;
        case NLHomeSectionStylePlayListBig:
            return 330;
        default:
            return 240;
    }
}

-(void)handlePlayListSelected:(NLRecommendAlbumListModel *)model {
  NSLog(@"点击歌单：%@  id: %ld", model.name, (long)model.playlistId);
}

#pragma mark - Section 间距控制（非常重要）

- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section {
    return 10;   // 两个 cell 之间的“上间距”
}

- (CGFloat)tableView:(UITableView *)tableView
heightForFooterInSection:(NSInteger)section {
    return 0.01; // 必须 >0，否则 grouped 会给默认高度
}

- (UIView *)tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}

- (UIView *)tableView:(UITableView *)tableView
viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}


@end
