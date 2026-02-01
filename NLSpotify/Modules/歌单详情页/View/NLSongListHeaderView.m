//
//  NLSongListHeaderView.m
//  NLSpotify
//
//  Created by 吴桐 on 2026/1/8.
//

#import "NLSongListHeaderView.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>
#import "NLListCellModel.h"
#import "NLSingerAlbumListModel.h"

@interface NLSongListHeaderView ()

@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UIImageView *artistImageView;
@property (nonatomic, strong) UILabel *artistNameLabel;

// 顶部按钮
@property (nonatomic, strong) UIStackView *topStack;

// 底部按钮
@property (nonatomic, strong) UIButton *playAllButton;
@property (nonatomic, strong) UIButton *downloadButton;
@property (nonatomic, strong) UIButton *sortButton;

@end

@implementation NLSongListHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        self.backgroundColor = UIColor.clearColor;

        // 封面
        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.layer.cornerRadius = 10;
        _coverImageView.clipsToBounds = YES;
        [self addSubview:_coverImageView];

        // 标题
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:22];
        _titleLabel.textColor = UIColor.whiteColor;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 2;
        [self addSubview:_titleLabel];

        // 描述
        _descLabel = [[UILabel alloc] init];
        _descLabel.font = [UIFont systemFontOfSize:13];
        _descLabel.textColor = [UIColor colorWithWhite:1 alpha:0.6];
        _descLabel.textAlignment = NSTextAlignmentCenter;
        _descLabel.numberOfLines = 2;
        [self addSubview:_descLabel];

        // 作者头像
        _artistImageView = [[UIImageView alloc] init];
        _artistImageView.layer.cornerRadius = 16;
        _artistImageView.clipsToBounds = YES;
        [self addSubview:_artistImageView];

        // 作者名
        _artistNameLabel = [[UILabel alloc] init];
        _artistNameLabel.font = [UIFont systemFontOfSize:15];
        _artistNameLabel.textColor = [UIColor colorWithWhite:1 alpha:0.85];
        [self addSubview:_artistNameLabel];

        [self setupViews];
    }
    return self;
}

#pragma mark - Setup Views

- (void)setupViews {

    // 封面
    [_coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(120); // 从 80 增加到 120，让整体往下移
        make.centerX.equalTo(self);
        make.width.height.mas_equalTo(160);
    }];

    // 标题
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_coverImageView.mas_bottom).offset(16);
        make.left.right.equalTo(self).inset(20);
    }];

    // 描述
    [_descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleLabel.mas_bottom).offset(8);
        make.left.right.equalTo(self).inset(20);
    }];

    // 作者头像
    [_artistImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_descLabel.mas_bottom).offset(14);
        make.left.equalTo(self).offset(20);
        make.width.height.mas_equalTo(32);
    }];

    // 作者名
    [_artistNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_artistImageView);
        make.left.equalTo(_artistImageView.mas_right).offset(10);
    }];

    [self setupActionViews];
}

#pragma mark - Action Buttons

- (void)setupActionViews {

    // ===== 顶部按钮（转发 / 评论 / 喜欢）=====
    _topStack = [[UIStackView alloc] init];
    _topStack.axis = UILayoutConstraintAxisHorizontal;
    _topStack.spacing = 24;
    _topStack.alignment = UIStackViewAlignmentCenter;
    [self addSubview:_topStack];

    [_topStack addArrangedSubview:[self createTopItem:@"square.and.arrow.up" type:@"share"]];
    [_topStack addArrangedSubview:[self createTopItem:@"text.bubble" type:@"comment"]];
    [_topStack addArrangedSubview:[self createTopItem:@"heart" type:@"like"]];

    [_topStack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.artistImageView);
        make.right.equalTo(self).offset(-20);
    }];

    // ===== 底部按钮（播放全部 / 下载 / 排序）=====
    _playAllButton = [self createPlayAllButton];
    _downloadButton = [self createIconButton:@"arrow.down.circle"];
    _sortButton = [self createIconButton:@"line.3.horizontal.decrease"];

    [self addSubview:_playAllButton];
    [self addSubview:_downloadButton];
    [self addSubview:_sortButton];

    // Masonry 约束
    [_playAllButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(16);
        make.top.equalTo(self.artistImageView.mas_bottom).offset(24);
        make.height.mas_equalTo(44);
        make.width.greaterThanOrEqualTo(@140);
        make.bottom.equalTo(self).offset(-20).priority(999); // 底部约束，确保高度正确，避免内容重合
    }];

    [_downloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-16);
        make.centerY.equalTo(_playAllButton);
        make.width.height.mas_equalTo(44);
    }];

    [_sortButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_downloadButton.mas_left).offset(-12);
        make.centerY.equalTo(_playAllButton);
        make.width.height.mas_equalTo(44);
    }];
    
    // 设置底部约束，确保 headerView 高度正确计算，避免内容重合
    [_playAllButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(16);
        make.top.equalTo(self.artistImageView.mas_bottom).offset(24);
        make.height.mas_equalTo(44);
        make.width.greaterThanOrEqualTo(@140);
        make.bottom.equalTo(self).offset(-20).priority(999); // 底部约束，确保高度正确
    }];
}

#pragma mark - Top Items

- (UIView *)createTopItem:(NSString *)icon type:(NSString *)type {
    UIStackView *container = [[UIStackView alloc] init];
    container.axis = UILayoutConstraintAxisVertical;
    container.alignment = UIStackViewAlignmentCenter;
    container.spacing = 4;
    container.accessibilityIdentifier = type;

    UIImageView *iconView = [[UIImageView alloc] initWithImage:
        [[UIImage systemImageNamed:icon] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    iconView.tintColor = UIColor.whiteColor;

    UILabel *label = [[UILabel alloc] init];
    label.text = @"--";
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor colorWithWhite:1 alpha:0.7];

    [container addArrangedSubview:iconView];
    [container addArrangedSubview:label];

    UITapGestureRecognizer *tap =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(topItemTapped:)];
    [container addGestureRecognizer:tap];

    return container;
}

#pragma mark - Bottom Buttons

- (UIButton *)createPlayAllButton {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.layer.cornerRadius = 22;
    btn.clipsToBounds = YES;
    btn.backgroundColor = [UIColor colorWithWhite:1 alpha:0.12];

    [btn setTitle:@" 播放全部" forState:UIControlStateNormal];
    [btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:15];

    UIImage *icon = [[UIImage systemImageNamed:@"play.fill"]
        imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [btn setImage:icon forState:UIControlStateNormal];
    btn.tintColor = UIColor.whiteColor;

    [btn addTarget:self
            action:@selector(playAllTapped)
  forControlEvents:UIControlEventTouchUpInside];

    return btn;
}

- (UIButton *)createIconButton:(NSString *)iconName {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    UIImage *icon = [[UIImage systemImageNamed:iconName]
        imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [btn setImage:icon forState:UIControlStateNormal];
    btn.tintColor = UIColor.whiteColor;
    return btn;
}

#pragma mark - Actions

- (void)playAllTapped {
    if ([self.delegate respondsToSelector:@selector(headerViewDidTapPlayAll:)]) {
        [self.delegate headerViewDidTapPlayAll:self];
    }
}

- (void)topItemTapped:(UITapGestureRecognizer *)tap {
    NSString *type = tap.view.accessibilityIdentifier;
    if ([self.delegate respondsToSelector:@selector(headerView:didTapTopAction:)]) {
        [self.delegate headerView:self didTapTopAction:type];
    }
}

#pragma mark - Config

- (void)configWithPlayList:(NLHeaderModel *)playlist {
    if (!playlist) return;

    NSString *cover = [playlist.coverUrl stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"];
    NSString *avatar = [playlist.creatorAvatar stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"];

    [_coverImageView sd_setImageWithURL:[NSURL URLWithString:cover]];
    _titleLabel.text = playlist.name;
    _descLabel.text = playlist.desc.length ? playlist.desc : @"网易云音乐歌单";

    _artistNameLabel.text = playlist.creatorName;
    [_artistImageView sd_setImageWithURL:[NSURL URLWithString:avatar]
                        placeholderImage:[UIImage imageNamed:@"avatar_placeholder"]];
}

@end
