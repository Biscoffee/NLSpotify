//
//  NLDiscoveryCardCell.m
//  NLSpotify
//
//  Created by 吴桐 on 2026/1/16.
//

#import "NLDiscoveryCardCell.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>

@interface NLDiscoveryCardCell ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end

@implementation NLDiscoveryCardCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.contentView.layer.cornerRadius = 12;
    self.contentView.layer.masksToBounds = YES;

    // 容器视图
    _containerView = [[UIView alloc] init];
    [self.contentView addSubview:_containerView];

    // 背景图
    _backgroundImageView = [[UIImageView alloc] init];
    _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [_containerView addSubview:_backgroundImageView];

    // 渐变层
    _gradientLayer = [CAGradientLayer layer];
    _gradientLayer.colors = @[
        (id)[[UIColor clearColor] CGColor],
        (id)[[UIColor colorWithWhite:0 alpha:0.2] CGColor],
        (id)[[UIColor colorWithWhite:0 alpha:0.6] CGColor]
    ];
    _gradientLayer.locations = @[@0.0, @0.6, @1.0];
    _gradientLayer.startPoint = CGPointMake(0.5, 0);
    _gradientLayer.endPoint = CGPointMake(0.5, 1);

    // 标题
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont boldSystemFontOfSize:18];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.numberOfLines = 2;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [_containerView addSubview:_titleLabel];

    // 布局
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];

    [_backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_containerView);
    }];

    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_containerView).offset(12);
        make.right.equalTo(_containerView).offset(-12);
        make.bottom.equalTo(_containerView).offset(-12);
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _gradientLayer.frame = self.containerView.bounds;
    [self.containerView.layer insertSublayer:_gradientLayer atIndex:0];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    _backgroundImageView.image = nil;
    _titleLabel.text = nil;
}

- (void)setModel:(NLDiscoveryCardModel *)model {
    _model = model;

    // 设置背景图片
    if (model.imageName.length > 0) {
        _backgroundImageView.image = [UIImage imageNamed:model.imageName];
    }

    // 如果没有图片，使用纯色背景
    if (!_backgroundImageView.image) {
        UIColor *backgroundColor = [self colorFromHexString:model.backgroundColorHex];
        _containerView.backgroundColor = backgroundColor;
    } else {
        _containerView.backgroundColor = [UIColor clearColor];
    }

    // 设置标题
    _titleLabel.text = model.title;

    // 根据标题内容调整字体大小
    if (model.title.length > 6) {
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
    } else {
        _titleLabel.font = [UIFont boldSystemFontOfSize:18];
    }
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    if (!hexString || hexString.length < 7) {
        return [UIColor darkGrayColor];
    }

    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // 跳过 '#'
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0
                           green:((rgbValue & 0xFF00) >> 8)/255.0
                            blue:(rgbValue & 0xFF)/255.0
                           alpha:1.0];
}

@end
