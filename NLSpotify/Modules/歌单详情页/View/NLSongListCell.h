//
//  NLSongCell.h
//  NLSpotify
//
//  Created by 吴桐 on 2026/1/8.
//

#import <UIKit/UIKit.h>
#import "NLListCellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NLSongListCell : UITableViewCell

- (void)configWithSong:(NLListCellModel *)song;

@end

NS_ASSUME_NONNULL_END
