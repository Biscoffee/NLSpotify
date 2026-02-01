//
//  NLDrawerViewController.m
//  NLSpotify
//

#import "NLDrawerViewController.h"
#import "NLDrawerView.h"
#import "NLDrawerModels.h"

@interface NLDrawerViewController () <NLDrawerViewDelegate>
@property (nonatomic, strong) NLDrawerProfileModel *profileModel;
@property (nonatomic, copy) NSArray<NLDrawerMenuItem *> *menuItems;
@property (nonatomic, strong) NLDrawerMessageSectionModel *messageSectionModel;
@end

@implementation NLDrawerViewController

- (void)loadView {
    self.view = [[NLDrawerView alloc] initWithFrame:CGRectZero];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _profileModel = [NLDrawerProfileModel defaultModel];
    _menuItems = [NLDrawerMenuItem defaultMenuItems];
    _messageSectionModel = [NLDrawerMessageSectionModel defaultModel];

    NLDrawerView *drawerView = (NLDrawerView *)self.view;
    drawerView.delegate = self;
    [drawerView configWithProfile:_profileModel
                       menuItems:_menuItems
                  messageSection:_messageSectionModel];
}

#pragma mark - NLDrawerViewDelegate

- (void)drawerView:(NLDrawerView *)drawerView didSelectMenuAtIndex:(NSInteger)index {
    if (index < 0 || index >= (NSInteger)_menuItems.count) return;
    if ([self.delegate respondsToSelector:@selector(drawerController:didSelectMenuAtIndex:)]) {
        [self.delegate drawerController:self didSelectMenuAtIndex:index];
    }
    if (self.onRequestClose) self.onRequestClose();
}

- (void)drawerViewDidTapProfile:(NLDrawerView *)drawerView {
    if ([self.delegate respondsToSelector:@selector(drawerControllerDidTapProfile:)]) {
        [self.delegate drawerControllerDidTapProfile:self];
    }
}

- (void)drawerViewDidTapStatusButton:(NLDrawerView *)drawerView {
    if ([self.delegate respondsToSelector:@selector(drawerControllerDidTapStatusButton:)]) {
        [self.delegate drawerControllerDidTapStatusButton:self];
    }
}

- (void)drawerViewDidTapNewMessage:(NLDrawerView *)drawerView {
    if ([self.delegate respondsToSelector:@selector(drawerControllerDidTapNewMessage:)]) {
        [self.delegate drawerControllerDidTapNewMessage:self];
    }
}

@end
