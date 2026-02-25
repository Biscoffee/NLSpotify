//
//  NLPlayListSongRelation.h
//  NLSpotify
//
//  Created by 吴桐 on 2026/2/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NLPlayListSongRelation : NSObject

@property (nonatomic, copy) NSString *playlistId; // 属于哪个歌单
@property (nonatomic, copy) NSString *songId;     // 包含哪首歌
@property (nonatomic, assign) NSTimeInterval addTime; // 添加进去的时间

- (instancetype)initWithPlaylistId:(NSString *)playlistId songId:(NSString *)songId;

@end

NS_ASSUME_NONNULL_END
