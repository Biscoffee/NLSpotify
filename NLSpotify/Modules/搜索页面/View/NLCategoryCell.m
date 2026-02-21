//
//  NLCategoryCell.m
//  NLSpotify
//

#import "NLCategoryCell.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>

@interface NLCategoryCell ()

@property (nonatomic, strong) UIView *containerView;       // 背景容器
@property (nonatomic, strong) UIImageView *coverImageView;   // 格子背景：封面图铺满
@property (nonatomic, strong) UIView *coverOverlay;         // 深色遮罩保证文字可读
@property (nonatomic, strong) UILabel *nameLabel;            // 左上角标题

@end

@implementation NLCategoryCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

#pragma mark - UI

- (void)setupUI {
    self.contentView.backgroundColor = UIColor.clearColor;

    _containerView = [[UIView alloc] init];
    _containerView.layer.cornerRadius = 12;
    _containerView.layer.masksToBounds = YES;
    [self.contentView addSubview:_containerView];

    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];

    // 格子背景：封面图铺满整格
    _coverImageView = [[UIImageView alloc] init];
    _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    _coverImageView.clipsToBounds = YES;
    [_containerView addSubview:_coverImageView];
    [_coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_containerView);
    }];

    // 深色遮罩，保证标题可读
    _coverOverlay = [[UIView alloc] init];
    _coverOverlay.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    [_containerView addSubview:_coverOverlay];
    [_coverOverlay mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_containerView);
    }];

    _nameLabel = [[UILabel alloc] init];
    _nameLabel.font = [UIFont boldSystemFontOfSize:16];
    _nameLabel.textColor = UIColor.whiteColor; // 保持白色，文字在深色遮罩上需保证可读性
    _nameLabel.numberOfLines = 2;
    [_containerView addSubview:_nameLabel];

    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(_containerView).offset(12);
        make.right.lessThanOrEqualTo(_containerView).offset(-12);
    }];
}

#pragma mark - Model

- (void)setModel:(NLCategoryModel *)model {
    _model = model;
    _nameLabel.text = model.name;

    // 有封面用封面铺满格子背景，没有则用分类色
    if (model.previewCoverUrl.length > 0) {
        NSString *url = [model.previewCoverUrl stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"];
        [_coverImageView sd_setImageWithURL:[NSURL URLWithString:url]];
        _coverImageView.hidden = NO;
        _coverOverlay.hidden = NO;
        _containerView.backgroundColor = UIColor.clearColor;
    } else {
        _coverImageView.image = nil;
        _coverImageView.hidden = YES;
        _coverOverlay.hidden = YES;
        NSString *hex = model.backgroundColorHex ?: @"#1DB954";
        _containerView.backgroundColor = [self colorFromHexString:hex];
    }
}

#pragma mark - Utils

- (UIColor *)colorFromHexString:(NSString *)hexString {
    if (hexString.length < 7) return UIColor.grayColor;

    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1];
    [scanner scanHexInt:&rgbValue];

    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0
                           green:((rgbValue & 0xFF00) >> 8)/255.0
                            blue:(rgbValue & 0xFF)/255.0
                           alpha:1.0];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    _coverImageView.image = nil;
    _coverImageView.hidden = NO;
    _coverOverlay.hidden = NO;
    _containerView.backgroundColor = nil;
}

@end

