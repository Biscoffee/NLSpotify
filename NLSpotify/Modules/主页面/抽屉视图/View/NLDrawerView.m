//
//  NLDrawerView.m
//  NLSpotify
//

#import "NLDrawerView.h"
#import "NLDrawerModels.h"
#import <Masonry/Masonry.h>

static const CGFloat kMenuRowHeight = 52.f;
static const CGFloat kMenuTopInset = 8.f;
static const CGFloat kProfileTopInset = 62.f;
static const CGFloat kProfileSectionHeight = 100.f;
static const CGFloat kMessageSectionHeight = 180.f;
static const CGFloat kMessageBottomInset = 40.f;
static const CGFloat kSeparatorHeight = 1.f;
static const CGFloat kMessageSectionTopOffset = 8.f;

@interface NLDrawerView ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *profileSection;
@property (nonatomic, strong) UIView *menuSection;
@property (nonatomic, strong) UIView *messageSection;
@property (nonatomic, strong) UIView *separatorView;
@property (nonatomic, copy) NSArray<NLDrawerMenuItem *> *menuItems;
@end

@implementation NLDrawerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor systemBackgroundColor];
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.alwaysBounceVertical = YES;
        [self addSubview:_scrollView];

        _contentView = [[UIView alloc] init];
        [_scrollView addSubview:_contentView];

        _profileSection = [[UIView alloc] init];
        [_contentView addSubview:_profileSection];

        _separatorView = [[UIView alloc] init];
        _separatorView.backgroundColor = [UIColor separatorColor];
        [_contentView addSubview:_separatorView];

        _menuSection = [[UIView alloc] init];
        [_contentView addSubview:_menuSection];

        _messageSection = [[UIView alloc] init];
        [_contentView addSubview:_messageSection];
    }
    return self;
}

- (void)configWithProfile:(NLDrawerProfileModel *)profile
               menuItems:(NSArray<NLDrawerMenuItem *> *)menuItems
          messageSection:(NLDrawerMessageSectionModel *)messageSection {
    _menuItems = [menuItems copy];
    [self buildProfileSectionWith:profile];
    [self buildMenuSectionWith:menuItems];
    [self buildMessageSectionWith:messageSection];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)buildProfileSectionWith:(NLDrawerProfileModel *)profile {
    for (UIView *sub in _profileSection.subviews) [sub removeFromSuperview];

    UIView *profileTapArea = [[UIView alloc] init];
    profileTapArea.userInteractionEnabled = YES;
    [_profileSection addSubview:profileTapArea];

    UIImageView *avatar = [[UIImageView alloc] init];
    if (profile.avatarImage) {
        avatar.image = profile.avatarImage;
    } else {
        avatar.image = [UIImage systemImageNamed:@"person.circle.fill"];
        avatar.tintColor = [UIColor tertiaryLabelColor];
    }
    avatar.backgroundColor = [UIColor tertiarySystemFillColor];
    avatar.layer.cornerRadius = 30;
    avatar.clipsToBounds = YES;
    avatar.contentMode = UIViewContentModeScaleAspectFill;
    [profileTapArea addSubview:avatar];

    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.text = profile.userName;
    nameLabel.font = [UIFont boldSystemFontOfSize:20];
    nameLabel.textColor = [UIColor labelColor];
    [profileTapArea addSubview:nameLabel];

    UILabel *profileLink = [[UILabel alloc] init];
    profileLink.text = profile.profileLinkText;
    profileLink.font = [UIFont systemFontOfSize:14];
    profileLink.textColor = [UIColor secondaryLabelColor];
    [profileTapArea addSubview:profileLink];

    UIButton *statusBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [statusBtn setTitle:profile.statusButtonTitle forState:UIControlStateNormal];
    [statusBtn setTitleColor:[UIColor labelColor] forState:UIControlStateNormal];
    statusBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    statusBtn.layer.borderColor = [UIColor separatorColor].CGColor;
    statusBtn.layer.borderWidth = 1;
    statusBtn.layer.cornerRadius = 8;
    [statusBtn addTarget:self action:@selector(handleStatusButtonTap) forControlEvents:UIControlEventTouchUpInside];
    [_profileSection addSubview:statusBtn];

    UITapGestureRecognizer *profileTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleProfileTap)];
    [profileTapArea addGestureRecognizer:profileTap];

    [profileTapArea mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(_profileSection);
        make.right.equalTo(statusBtn.mas_left).offset(-8);
    }];
    [avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(profileTapArea).offset(20);
        make.top.equalTo(profileTapArea).offset(20);
        make.size.mas_equalTo(CGSizeMake(60, 60));
    }];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(avatar.mas_right).offset(16);
        make.top.equalTo(avatar).offset(4);
        make.right.lessThanOrEqualTo(profileTapArea).offset(-8);
    }];
    [profileLink mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(nameLabel);
        make.top.equalTo(nameLabel.mas_bottom).offset(4);
    }];
    [statusBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_profileSection).offset(-20);
        make.centerY.equalTo(avatar);
        make.height.mas_equalTo(32);
        make.width.mas_greaterThanOrEqualTo(90);
    }];
}

- (void)buildMenuSectionWith:(NSArray<NLDrawerMenuItem *> *)items {
    for (UIView *sub in _menuSection.subviews) [sub removeFromSuperview];

    UIView *lastRow = nil;
    for (NSInteger i = 0; i < items.count; i++) {
        NLDrawerMenuItem *item = items[i];
        UIView *row = [self menuRowWithItem:item index:i];
        [_menuSection addSubview:row];
        [row mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_menuSection);
            make.height.mas_equalTo(kMenuRowHeight);
            if (lastRow) make.top.equalTo(lastRow.mas_bottom);
            else make.top.equalTo(_menuSection).offset(kMenuTopInset);
        }];
        lastRow = row;
    }
}

- (UIView *)menuRowWithItem:(NLDrawerMenuItem *)item index:(NSInteger)index {
    UIView *row = [[UIView alloc] init];
    row.tag = index;

    UIImageView *icon = [[UIImageView alloc] init];
    icon.image = [UIImage systemImageNamed:item.iconName];
    icon.tintColor = [UIColor labelColor];
    icon.contentMode = UIViewContentModeScaleAspectFit;
    [row addSubview:icon];

    UILabel *label = [[UILabel alloc] init];
    label.text = item.title;
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor labelColor];
    if (item.highlightNew) {
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:item.title];
        NSRange range = [item.title rangeOfString:@"・新增"];
        if (range.location != NSNotFound) {
            [attr addAttribute:NSForegroundColorAttributeName value:[UIColor systemBlueColor] range:range];
        }
        label.attributedText = attr;
    }
    [row addSubview:label];

    [icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(row).offset(20);
        make.centerY.equalTo(row);
        make.size.mas_equalTo(CGSizeMake(24, 24));
    }];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(icon.mas_right).offset(16);
        make.centerY.equalTo(row);
    }];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMenuRowTap:)];
    [row addGestureRecognizer:tap];
    row.userInteractionEnabled = YES;
    return row;
}

- (void)handleMenuRowTap:(UITapGestureRecognizer *)gesture {
    NSInteger index = gesture.view.tag;
    if ([self.delegate respondsToSelector:@selector(drawerView:didSelectMenuAtIndex:)]) {
        [self.delegate drawerView:self didSelectMenuAtIndex:index];
    }
}

- (void)handleProfileTap {
    if ([self.delegate respondsToSelector:@selector(drawerViewDidTapProfile:)]) {
        [self.delegate drawerViewDidTapProfile:self];
    }
}

- (void)handleStatusButtonTap {
    if ([self.delegate respondsToSelector:@selector(drawerViewDidTapStatusButton:)]) {
        [self.delegate drawerViewDidTapStatusButton:self];
    }
}

- (void)buildMessageSectionWith:(NLDrawerMessageSectionModel *)model {
    for (UIView *sub in _messageSection.subviews) [sub removeFromSuperview];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = model.sectionTitle;
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.textColor = [UIColor labelColor];
    [_messageSection addSubview:titleLabel];

    UILabel *descLabel = [[UILabel alloc] init];
    descLabel.text = model.sectionDescription;
    descLabel.font = [UIFont systemFontOfSize:14];
    descLabel.textColor = [UIColor secondaryLabelColor];
    descLabel.numberOfLines = 0;
    [_messageSection addSubview:descLabel];

    UIView *newMessageRow = [[UIView alloc] init];
    UIImageView *icon = [[UIImageView alloc] init];
    icon.image = [UIImage systemImageNamed:model.messageItemIconName];
    icon.tintColor = [UIColor labelColor];
    icon.contentMode = UIViewContentModeScaleAspectFit;
    [newMessageRow addSubview:icon];
    UILabel *msgLabel = [[UILabel alloc] init];
    msgLabel.text = model.messageItemTitle;
    msgLabel.font = [UIFont systemFontOfSize:16];
    msgLabel.textColor = [UIColor labelColor];
    [newMessageRow addSubview:msgLabel];
    [_messageSection addSubview:newMessageRow];

    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_messageSection).offset(20);
        make.top.equalTo(_messageSection).offset(24);
    }];
    [descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_messageSection).inset(20);
        make.top.equalTo(titleLabel.mas_bottom).offset(8);
    }];
    [icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(newMessageRow).offset(20);
        make.centerY.equalTo(newMessageRow);
        make.size.mas_equalTo(CGSizeMake(24, 24));
    }];
    [msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(icon.mas_right).offset(16);
        make.centerY.equalTo(newMessageRow);
    }];
    [newMessageRow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_messageSection);
        make.top.equalTo(descLabel.mas_bottom).offset(16);
        make.height.mas_equalTo(52);
    }];

    newMessageRow.userInteractionEnabled = YES;
    UITapGestureRecognizer *newMsgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleNewMessageTap)];
    [newMessageRow addGestureRecognizer:newMsgTap];
}

- (void)handleNewMessageTap {
    if ([self.delegate respondsToSelector:@selector(drawerViewDidTapNewMessage:)]) {
        [self.delegate drawerViewDidTapNewMessage:self];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [_scrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [_contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_scrollView);
        make.width.equalTo(_scrollView);
    }];

    [_profileSection mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_contentView);
        make.top.equalTo(_contentView).offset(kProfileTopInset);
        make.height.mas_equalTo(kProfileSectionHeight);
    }];

    [_separatorView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_contentView);
        make.top.equalTo(_profileSection.mas_bottom);
        make.height.mas_equalTo(kSeparatorHeight);
    }];

    NSUInteger menuCount = _menuItems.count;
    [_menuSection mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_contentView);
        make.top.equalTo(_separatorView.mas_bottom);
        make.height.mas_equalTo(kMenuTopInset + menuCount * kMenuRowHeight);
    }];

    [_messageSection mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_contentView);
        make.top.equalTo(_menuSection.mas_bottom).offset(kMessageSectionTopOffset);
        make.height.mas_equalTo(kMessageSectionHeight);
        make.bottom.equalTo(_contentView).offset(-kMessageBottomInset);
    }];
}

@end
