//
//  NLPlaylistCollectionCell.h
//  NLSpotify
//
//  Created by 吴桐 on 2026/1/17.
//

#import <UIKit/UIKit.h>
#import "NLPlayListModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NLPlaylistCollectionCell : UICollectionViewCell

@property (nonatomic, strong) NLPlaylistModel *playlist;

@end

NS_ASSUME_NONNULL_END
