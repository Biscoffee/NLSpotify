//
//  NLSongListCell.m
//  NLSpotify
//

#import "NLSongListCell.h"
#import "NLListCellModel.h"
#import "NLSong.h"
#import "NLPlayList.h"
#import "NLAlbum.h"
#import <Masonry/Masonry.h>
#import "SDWebImage/SDWebImage.h"

@interface NLSongListCell ()
@property (nonatomic, strong) UIImageView *thumbImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *artistLabel;
@property (nonatomic, strong) UIButton *moreButton;
@end

@implementation NLSongListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor systemBackgroundColor];
        self.selectionStyle = UITableViewCellSelectionStyleGray;

        _thumbImageView = [[UIImageView alloc] init];
        _thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbImageView.clipsToBounds = YES;
        _thumbImageView.layer.cornerRadius = 4;
        _thumbImageView.backgroundColor = [UIColor tertiarySystemFillColor];
        [self.contentView addSubview:_thumbImageView];

        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [UIColor labelColor];
        _nameLabel.font = [UIFont systemFontOfSize:16];
        _nameLabel.numberOfLines = 1;
        [self.contentView addSubview:_nameLabel];

        _artistLabel = [[UILabel alloc] init];
        _artistLabel.textColor = [UIColor secondaryLabelColor];
        _artistLabel.font = [UIFont systemFontOfSize:14];
        _artistLabel.numberOfLines = 1;
        [self.contentView addSubview:_artistLabel];

        _moreButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_moreButton setImage:[UIImage systemImageNamed:@"ellipsis"] forState:UIControlStateNormal];
        _moreButton.tintColor = [UIColor secondaryLabelColor];
        [self.contentView addSubview:_moreButton];

        [_thumbImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(16);
            make.centerY.equalTo(self.contentView);
            make.size.mas_equalTo(CGSizeMake(48, 48));
        }];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_thumbImageView.mas_right).offset(12);
            make.right.lessThanOrEqualTo(_moreButton.mas_left).offset(-8);
            make.top.equalTo(self.contentView).offset(12);
        }];
        [_artistLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_nameLabel);
            make.top.equalTo(_nameLabel.mas_bottom).offset(2);
        }];
        [_moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-12);
            make.centerY.equalTo(self.contentView);
            make.size.mas_equalTo(CGSizeMake(44, 44));
        }];
    }
    return self;
}

- (void)configWithSong:(NLListCellModel *)song {
    _nameLabel.text = song.name ?: @"";
    _artistLabel.text = song.artistName ?: @"";
    if (song.coverUrl.length > 0) {
        NSString *url = [song.coverUrl stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"];
        [_thumbImageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil];
    } else {
        _thumbImageView.image = nil;
    }
}

- (void)configWithNLSong:(NLSong *)song {
    _nameLabel.text = song.title ?: @"";
    _artistLabel.text = song.artist ?: @"";
    if (song.coverURL) {
        [_thumbImageView sd_setImageWithURL:song.coverURL placeholderImage:nil];
    } else {
        _thumbImageView.image = nil;
    }
}

- (void)configWithPlayList:(NLPlayList *)playList {
    _nameLabel.text = playList.name.length ? playList.name : @"歌单";
    _artistLabel.text = @"歌单";
    if (playList.coverURL.length > 0) {
        [_thumbImageView sd_setImageWithURL:[NSURL URLWithString:playList.coverURL] placeholderImage:nil];
    } else {
        _thumbImageView.image = nil;
        _thumbImageView.backgroundColor = [UIColor tertiarySystemFillColor];
    }
}

- (void)configWithAlbum:(NLAlbum *)album {
    _nameLabel.text = album.name.length ? album.name : @"专辑";
    _artistLabel.text = album.artistName.length ? album.artistName : @"专辑";
    if (album.coverURL.length > 0) {
        [_thumbImageView sd_setImageWithURL:[NSURL URLWithString:album.coverURL] placeholderImage:nil];
    } else {
        _thumbImageView.image = nil;
        _thumbImageView.backgroundColor = [UIColor tertiarySystemFillColor];
    }
}

@end
