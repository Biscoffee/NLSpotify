//
//  NLPlaylistCollectionCell.m
//  NLSpotify
//
//  Created by 吴桐 on 2026/1/17.
//

#import "NLPlaylistCollectionCell.h"
#import <SDWebImage/SDWebImage.h>
#import "Masonry/Masonry.h"

@interface NLPlaylistCollectionCell ()

@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *creatorLabel;

@end

@implementation NLPlaylistCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.contentView.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
    self.contentView.layer.cornerRadius = 8;
    self.contentView.layer.masksToBounds = YES;

    _coverImageView = [[UIImageView alloc] init];
    _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    _coverImageView.layer.cornerRadius = 4;
    _coverImageView.clipsToBounds = YES;
    [self.contentView addSubview:_coverImageView];

    _nameLabel = [[UILabel alloc] init];
    _nameLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    _nameLabel.textColor = [UIColor labelColor];
    _nameLabel.numberOfLines = 2;
    [self.contentView addSubview:_nameLabel];

    _creatorLabel = [[UILabel alloc] init];
    _creatorLabel.font = [UIFont systemFontOfSize:12];
    _creatorLabel.textColor = [UIColor secondaryLabelColor];
    [self.contentView addSubview:_creatorLabel];

    // 布局
    [_coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.contentView).inset(8);
        make.height.equalTo(_coverImageView.mas_width);
    }];

    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_coverImageView.mas_bottom).offset(8);
        make.left.right.equalTo(self.contentView).inset(8);
    }];

    [_creatorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_nameLabel.mas_bottom).offset(4);
        make.left.right.equalTo(self.contentView).inset(8);
        make.bottom.lessThanOrEqualTo(self.contentView).offset(-8);
    }];
}

- (void)setPlaylist:(NLPlaylistModel *)playlist {
    _playlist = playlist;

    // 封面图
    if (playlist.coverImgUrl.length > 0) {
        NSString *urlString = [playlist.coverImgUrl stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"];
        NSURL *url = [NSURL URLWithString:urlString];
        [_coverImageView sd_setImageWithURL:url
                           placeholderImage:[UIImage imageNamed:@"default_cover"]];
    }

    _nameLabel.text = playlist.name;
    _creatorLabel.text = [NSString stringWithFormat:@"by %@", playlist.creatorName];
}

@end
