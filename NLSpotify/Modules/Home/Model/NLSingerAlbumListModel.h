//
//  NLSingerListModel.h
//  NLSpotify
//
//  Created by 吴桐 on 2025/12/15.
//
// 对应某位歌手的专辑（...的粉丝特供）

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NLSingerAlbumListModel : NSObject

@property (nonatomic, copy) NSString *cardId;

@property (nonatomic, copy) NSString *coverUrl;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@property (nonatomic, copy) NSString *singer;
@property (nonatomic, copy) NSString *singerUrl;
@end

NS_ASSUME_NONNULL_END
