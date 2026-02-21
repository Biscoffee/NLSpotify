//  NLSearchAdBannerView.m
//  NLSpotify
//
//  Created by ChatGPT on 2026/1/24.
//

#import "NLSearchAdBannerView.h"
#import <Masonry/Masonry.h>

@implementation NLSearchAdBannerView {
  UIButton *_closeButton;
  UIButton *_experienceButton;
}

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self setupUI];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
  self = [super initWithCoder:coder];
  if (self) {
    [self setupUI];
  }
  return self;
}

- (void)setupUI {
  UIColor *appleRed = [UIColor colorWithRed:0.92 green:0.22 blue:0.21 alpha:1];
  CGFloat headerH = 72;
  CGFloat cornerR = 12;

  self.backgroundColor = appleRed;
  self.layer.cornerRadius = cornerR;
  self.clipsToBounds = YES;

  // 顶部红色 Header：apple.logo + Music
  UIView *redHeader = [[UIView alloc] init];
  redHeader.backgroundColor = appleRed;
  [self addSubview:redHeader];

  UIView *logoTitleContainer = [[UIView alloc] init];
  [redHeader addSubview:logoTitleContainer];

  UIImage *appleLogo = [UIImage systemImageNamed:@"apple.logo"];
  if (appleLogo) {
    appleLogo = [appleLogo imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  }
  UIImageView *appleLogoView = [[UIImageView alloc] initWithImage:appleLogo];
  appleLogoView.tintColor = UIColor.whiteColor;
  appleLogoView.contentMode = UIViewContentModeScaleAspectFit;
  [logoTitleContainer addSubview:appleLogoView];

  UILabel *musicLabel = [[UILabel alloc] init];
  musicLabel.text = @"Music";
  musicLabel.font = [UIFont boldSystemFontOfSize:24];
  musicLabel.textColor = UIColor.whiteColor;
  [logoTitleContainer addSubview:musicLabel];

  _closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
  [_closeButton setImage:[UIImage systemImageNamed:@"xmark"] forState:UIControlStateNormal];
  _closeButton.tintColor = [UIColor colorWithWhite:1 alpha:0.9];
  _closeButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
  _closeButton.layer.cornerRadius = 15;
  [_closeButton addTarget:self action:@selector(handleCloseTapped) forControlEvents:UIControlEventTouchUpInside];
  [self addSubview:_closeButton];

  // 主体区域
  UIView *whiteBody = [[UIView alloc] init];
  whiteBody.backgroundColor = [UIColor systemBackgroundColor];
  whiteBody.layer.cornerRadius = cornerR;
  whiteBody.layer.maskedCorners = kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
  [self addSubview:whiteBody];

  UILabel *headlineLabel = [[UILabel alloc] init];
  headlineLabel.text = @"唱响数千万歌曲，全无广告干扰";
  headlineLabel.font = [UIFont boldSystemFontOfSize:18];
  headlineLabel.textColor = [UIColor labelColor];
  headlineLabel.numberOfLines = 2;
  headlineLabel.textAlignment = NSTextAlignmentCenter;
  [whiteBody addSubview:headlineLabel];

  UILabel *descLabel = [[UILabel alloc] init];
  descLabel.text = @"你还能在所有设备上欣赏自己的整个音乐资料库。方案将以 ¥11.00/月的价格自动续期。";
  descLabel.font = [UIFont systemFontOfSize:14];
  descLabel.textColor = [UIColor secondaryLabelColor];
  descLabel.numberOfLines = 0;
  descLabel.textAlignment = NSTextAlignmentCenter;
  [whiteBody addSubview:descLabel];

  _experienceButton = [UIButton buttonWithType:UIButtonTypeSystem];
  [_experienceButton setTitle:@"立即体验" forState:UIControlStateNormal];
  [_experienceButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
  _experienceButton.backgroundColor = appleRed;
  _experienceButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
  _experienceButton.layer.cornerRadius = 24;
  _experienceButton.clipsToBounds = YES;
  [_experienceButton addTarget:self action:@selector(handleExperienceTapped) forControlEvents:UIControlEventTouchUpInside];
  [whiteBody addSubview:_experienceButton];

  UIButton *planLink = [UIButton buttonWithType:UIButtonTypeSystem];
  [planLink setTitle:@"查看所有方案" forState:UIControlStateNormal];
  [planLink setTitleColor:[UIColor secondaryLabelColor] forState:UIControlStateNormal];
  planLink.titleLabel.font = [UIFont systemFontOfSize:15];
  [whiteBody addSubview:planLink];

  // 布局
  [redHeader mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.left.right.equalTo(self);
    make.height.mas_equalTo(headerH);
  }];

  [logoTitleContainer mas_makeConstraints:^(MASConstraintMaker *make) {
    make.center.equalTo(redHeader);
  }];

  [appleLogoView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.centerY.equalTo(logoTitleContainer);
    make.width.height.mas_equalTo(26);
  }];

  [musicLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(appleLogoView.mas_right).offset(6);
    make.right.centerY.equalTo(logoTitleContainer);
  }];

  [_closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self).offset(12);
    make.right.equalTo(self).offset(-12);
    make.width.height.mas_equalTo(30);
  }];

  [whiteBody mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(redHeader.mas_bottom);
    make.left.right.bottom.equalTo(self);
  }];

  [headlineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(whiteBody).offset(20);
    make.left.equalTo(whiteBody).offset(24);
    make.right.equalTo(whiteBody).offset(-24);
  }];

  [descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(headlineLabel.mas_bottom).offset(10);
    make.left.equalTo(whiteBody).offset(24);
    make.right.equalTo(whiteBody).offset(-24);
  }];

  [_experienceButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(descLabel.mas_bottom).offset(18);
    make.left.equalTo(whiteBody).offset(24);
    make.right.equalTo(whiteBody).offset(-24);
    make.height.mas_equalTo(48);
  }];

  [planLink mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(_experienceButton.mas_bottom).offset(10);
    make.centerX.equalTo(whiteBody);
    make.bottom.equalTo(whiteBody).offset(-20);
  }];
}

- (void)handleExperienceTapped {
  if (self.onExperienceTapped) {
    self.onExperienceTapped();
  }
}

- (void)handleCloseTapped {
  if (self.onCloseTapped) {
    self.onCloseTapped();
  }
}

@end

