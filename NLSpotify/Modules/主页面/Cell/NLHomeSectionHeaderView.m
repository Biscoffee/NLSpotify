//
//  NLHomeSectionHeaderView.m
//  NLSpotify
//

#import "NLHomeSectionHeaderView.h"
#import "NLSectionViewModel.h"
#import "NLSingerAlbumListModel.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>

const CGFloat NLHomeSectionHeaderHeight = 52.f;
@interface NLHomeSectionHeaderView ()
@property (nonatomic, strong) UIImageView *singerAvatarView;
@property (nonatomic, strong) UILabel *labelSmall;   // 「的粉丝特供」
@property (nonatomic, strong) UILabel *singerNameLabel;
@end

@implementation NLHomeSectionHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor systemBackgroundColor];
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:21];
        _titleLabel.textColor = [UIColor labelColor];
        [self.contentView addSubview:_titleLabel];

        _singerAvatarView = [[UIImageView alloc] init];
        _singerAvatarView.layer.cornerRadius = 18;
        _singerAvatarView.clipsToBounds = YES;
        _singerAvatarView.backgroundColor = [UIColor tertiarySystemFillColor];
        _singerAvatarView.hidden = YES;
        [self.contentView addSubview:_singerAvatarView];

        _labelSmall = [[UILabel alloc] init];
        _labelSmall.font = [UIFont systemFontOfSize:12];
        _labelSmall.textColor = [UIColor secondaryLabelColor];
        _labelSmall.text = @"的粉丝特供";
        _labelSmall.hidden = YES;
        [self.contentView addSubview:_labelSmall];

        _singerNameLabel = [[UILabel alloc] init];
        _singerNameLabel.font = [UIFont boldSystemFontOfSize:16];
        _singerNameLabel.textColor = [UIColor labelColor];
        _singerNameLabel.hidden = YES;
        [self.contentView addSubview:_singerNameLabel];

        _disclosureImageView = [[UIImageView alloc] init];
        UIImage *chevron = [UIImage systemImageNamed:@"chevron.down"];
        if (chevron) _disclosureImageView.image = [chevron imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _disclosureImageView.tintColor = [UIColor secondaryLabelColor];
        _disclosureImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_disclosureImageView];

        UIButton *arrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
        arrowButton.backgroundColor = [UIColor clearColor];
        [arrowButton addTarget:self action:@selector(headerTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:arrowButton];
        [arrowButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-16);
            make.centerY.equalTo(self.contentView);
            make.size.mas_equalTo(CGSizeMake(44, 44));
        }];

        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(16);
            make.centerY.equalTo(self.contentView);
            make.right.lessThanOrEqualTo(_disclosureImageView.mas_left).offset(-8);
        }];
        [_singerAvatarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(16);
            make.centerY.equalTo(self.contentView);
            make.width.height.mas_equalTo(36);
        }];
        [_labelSmall mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_singerAvatarView.mas_top);
            make.left.equalTo(_singerAvatarView.mas_right).offset(16);
            make.right.lessThanOrEqualTo(_disclosureImageView.mas_left).offset(-8);
        }];
        [_singerNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_labelSmall.mas_bottom).offset(2);
            make.left.equalTo(_labelSmall);
            make.right.lessThanOrEqualTo(_disclosureImageView.mas_left).offset(-8);
        }];
        [_disclosureImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-16);
            make.centerY.equalTo(self.contentView);
            make.width.height.mas_equalTo(20);
        }];
    }
    return self;
}

- (void)headerTapped {
    if (self.didTapHeader) self.didTapHeader(self.sectionIndex);
}

- (void)configWithTitle:(NSString *)title collapsed:(BOOL)collapsed {
    _titleLabel.hidden = NO;
    _titleLabel.text = title ?: @"";
    _singerAvatarView.hidden = YES;
    _labelSmall.hidden = YES;
    _singerNameLabel.hidden = YES;
    _collapsed = collapsed;
    UIImage *img = collapsed ? [UIImage systemImageNamed:@"chevron.down"] : [UIImage systemImageNamed:@"chevron.up"];
    if (img) _disclosureImageView.image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (void)configWithSectionVM:(NLSectionViewModel *)sectionVM collapsed:(BOOL)collapsed {
    _collapsed = collapsed;
    UIImage *img = collapsed ? [UIImage systemImageNamed:@"chevron.down"] : [UIImage systemImageNamed:@"chevron.up"];
    if (img) _disclosureImageView.image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    if (sectionVM.style == NLHomeSectionStyleSingerAlbum && sectionVM.items.count > 0) {
        NLSingerAlbumListModel *first = (NLSingerAlbumListModel *)sectionVM.items.firstObject;
        _titleLabel.hidden = YES;
        _singerAvatarView.hidden = NO;
        _labelSmall.hidden = NO;
        _singerNameLabel.hidden = NO;
        _singerNameLabel.text = first.singer ?: @"";
        if (first.singerUrl.length > 0) {
            [_singerAvatarView sd_setImageWithURL:[NSURL URLWithString:first.singerUrl] placeholderImage:nil];
        } else {
            _singerAvatarView.image = nil;
        }
    } else {
        _titleLabel.hidden = NO;
        _titleLabel.text = sectionVM.title ?: @"";
        _singerAvatarView.hidden = YES;
        _labelSmall.hidden = YES;
        _singerNameLabel.hidden = YES;
    }
}

@end
