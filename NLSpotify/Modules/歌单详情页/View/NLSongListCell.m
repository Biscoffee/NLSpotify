//
//  NLSongCell.m
//  NLSpotify
//
//  Created by 吴桐 on 2026/1/8.
//

#import "NLSongListCell.h"
#import "NLListCellModel.h"
#import <Masonry/Masonry.h>
#import "SDWebImage/SDWebImage.h"


@interface NLSongListCell ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *artistLabel;

@end

@implementation NLSongListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        self.backgroundColor = UIColor.clearColor;

        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = UIColor.whiteColor;
        _nameLabel.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:_nameLabel];

        _artistLabel = [[UILabel alloc] init];
        _artistLabel.textColor = [UIColor colorWithWhite:1 alpha:0.6];
        _artistLabel.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:_artistLabel];

        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(10);
            make.left.right.equalTo(self.contentView).inset(16);
        }];

        [_artistLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_nameLabel.mas_bottom).offset(4);
            make.left.right.equalTo(_nameLabel);
            make.bottom.equalTo(self.contentView).offset(-10);
        }];
    }
    return self;
}

- (void)configWithSong:(NLListCellModel *)song {
    _nameLabel.text = song.name;
    _artistLabel.text = song.artistName;
}

@end
