//
//  NLDrawerViewController.m
//  NLSpotify
//

#import "NLDrawerViewController.h"
#import "NLDrawerView.h"
#import "NLDrawerModels.h"
#import <Masonry/Masonry.h>

static const CGFloat kDrawerMaxWidth = 320.f;
static const CGFloat kDrawerWidthRatio = 0.78f;

@interface NLDrawerViewController () <NLDrawerViewDelegate>
@property (nonatomic, strong) NLDrawerProfileModel *profileModel;
@property (nonatomic, copy) NSArray<NLDrawerMenuItem *> *menuItems;
@property (nonatomic, strong) NLDrawerMessageSectionModel *messageSectionModel;

@property (nonatomic, strong) UIView *dimmingView;
@property (nonatomic, strong) UIView *drawerContainerView;
@property (nonatomic, strong) NLDrawerView *drawerView;
@property (nonatomic, assign) CGFloat drawerWidth;
@end

@implementation NLDrawerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];

    _profileModel = [NLDrawerProfileModel defaultModel];
    _menuItems = [NLDrawerMenuItem defaultMenuItems];
    _messageSectionModel = [NLDrawerMessageSectionModel defaultModel];

    [self.view addSubview:self.dimmingView];
    [self.view addSubview:self.drawerContainerView];
    [self.drawerContainerView addSubview:self.drawerView];

    [self.dimmingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.drawerContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.view);
        make.width.mas_equalTo(self.drawerWidth);
        make.left.equalTo(self.view.mas_left).offset(-self.drawerWidth);
    }];
    [self.drawerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.drawerContainerView);
    }];

    [self.drawerView configWithProfile:_profileModel
                            menuItems:_menuItems
                       messageSection:_messageSectionModel];
}

#pragma mark - 弹出childVC和回缩childVC和Delegate

- (void)presentFromHostViewController:(UIViewController *)host {
    if (self.parentViewController) return;
    CGFloat w = host.view.bounds.size.width * kDrawerWidthRatio;
    _drawerWidth = w > kDrawerMaxWidth ? kDrawerMaxWidth : w;

    /* 添加子VC
     1. 建立关系，adddChild，addSubview, didMove...
     2. 初始状态
     */
    [host addChildViewController:self];
    [host.view addSubview:self.view];
    [self.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(host.view);
    }];
    [self didMoveToParentViewController:host];


    self.dimmingView.alpha = 0;
    // 在做动画值钱要先让布局确定下来，ai说的
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];

    [self.drawerContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.view);
        make.width.mas_equalTo(_drawerWidth);
        make.left.equalTo(self.view.mas_left);
    }];
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.dimmingView.alpha = 1;
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (void)dismissWithAnimation:(BOOL)animated completion:(void (^)(void))completion {
    __weak typeof(self) w = self;
    void (^removeDrawer)(void) = ^{
        [w willMoveToParentViewController:nil];
        [w.view removeFromSuperview];
        [w removeFromParentViewController];
        if (w.drawrDidDismiss) w.drawrDidDismiss();
        if (completion) completion();
    };
    if (!animated) {
        removeDrawer();
        return;
    }

    [self.drawerContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.view);
        make.width.mas_equalTo(self.drawerWidth);
        make.left.equalTo(self.view.mas_left).offset(-self.drawerWidth);
    }];
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.dimmingView.alpha = 0;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        removeDrawer();
    }];
}

- (void)drawerView:(NLDrawerView *)view didSelectMenuAtIndex:(NSInteger)index {
    if (index < 0 || index >= (NSInteger)_menuItems.count) return;
    if ([self.delegate respondsToSelector:@selector(drawerController:didSelectMenuAtIndex:)]) {
        [self.delegate drawerController:self didSelectMenuAtIndex:index];
    }
    [self dismissWithAnimation:YES completion:nil];
}

#pragma mark - Getters

- (UIView *)dimmingView {
    if (!_dimmingView) {
        _dimmingView = [[UIView alloc] init];
        _dimmingView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _dimmingView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dimmingTapped)];
        [_dimmingView addGestureRecognizer:tap];
    }
    return _dimmingView;
}

- (UIView *)drawerContainerView {
    if (!_drawerContainerView) {
        _drawerContainerView = [[UIView alloc] init];
        _drawerContainerView.backgroundColor = [UIColor clearColor];
    }
    return _drawerContainerView;
}

- (NLDrawerView *)drawerView {
    if (!_drawerView) {
        _drawerView = [[NLDrawerView alloc] initWithFrame:CGRectZero];
        _drawerView.delegate = self;
    }
    return _drawerView;
}

- (void)dimmingTapped {
    [self dismissWithAnimation:YES completion:nil];
}

@end
