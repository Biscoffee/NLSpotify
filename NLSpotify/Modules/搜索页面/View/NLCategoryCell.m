//
//  NLCategoryCell.m
//  NLSpotify
//

#import "NLCategoryCell.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>

@interface NLCategoryCell ()

@property (nonatomic, strong) UIView *containerView;    // 背景容器
@property (nonatomic, strong) UILabel *nameLabel;       // 左上角标题
@property (nonatomic, strong) UIView *coverShadowView;  // 封面阴影容器
@property (nonatomic, strong) UIImageView *coverImageView; // 封面图片

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

    // 主容器，纯色背景
    _containerView = [[UIView alloc] init];
    _containerView.layer.cornerRadius = 12;
    _containerView.layer.masksToBounds = YES;
    [self.contentView addSubview:_containerView];

    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];

    // 左上角标题
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.font = [UIFont boldSystemFontOfSize:16];
    _nameLabel.textColor = UIColor.whiteColor;
    _nameLabel.numberOfLines = 2;
    [_containerView addSubview:_nameLabel];

    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(_containerView).offset(12);
        make.right.lessThanOrEqualTo(_containerView).offset(-12);
    }];

    // 阴影容器（给封面一个轻微阴影）
    _coverShadowView = [[UIView alloc] init];
    _coverShadowView.layer.shadowColor = UIColor.blackColor.CGColor;
    _coverShadowView.layer.shadowOpacity = 0.25;
    _coverShadowView.layer.shadowRadius = 6;
    _coverShadowView.layer.shadowOffset = CGSizeMake(0, 3);
    [_containerView addSubview:_coverShadowView];

    // 封面图片
    _coverImageView = [[UIImageView alloc] init];
    _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    _coverImageView.layer.cornerRadius = 6;
    _coverImageView.clipsToBounds = YES;
    [_coverShadowView addSubview:_coverImageView];

    // 布局（右下角）
    [_coverShadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(75);
        make.right.bottom.equalTo(_containerView).offset(12);
    }];

    [_coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_coverShadowView);
    }];

    // 倾斜效果
    _coverShadowView.transform = CGAffineTransformMakeRotation(15 * M_PI / 180.0);
}

#pragma mark - Model

- (void)setModel:(NLCategoryModel *)model {
    _model = model;

    _nameLabel.text = model.name;

    // 背景颜色
    NSString *hex = model.backgroundColorHex ?: @"#1DB954";
    _containerView.backgroundColor = [self colorFromHexString:hex];

    // 封面
    if (model.previewCoverUrl.length > 0) {
        NSString *url = [model.previewCoverUrl stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"];
        [_coverImageView sd_setImageWithURL:[NSURL URLWithString:url]];
    } else {
        _coverImageView.image = nil;
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
    self.coverImageView.image = nil;
}

@end

