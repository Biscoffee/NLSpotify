//
//  NLSongModel.h
//  NLSpotify
//
//  Created by 吴桐 on 2026/1/8.
//

//每一个首单独的歌曲的Model
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NLListCellModel : NSObject

@property (nonatomic, assign) NSInteger songId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *artistName;
@property (nonatomic, copy) NSString *albumName;
@property (nonatomic, copy) NSString *coverUrl;
@property (nonatomic, assign) NSInteger duration;

@end

NS_ASSUME_NONNULL_END
