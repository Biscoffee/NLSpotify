//
//  NLAlbumRepository.h
//  NLSpotify
//
//  Created by 吴桐 on 2026/2/23.
//


#import <Foundation/Foundation.h>

@class NLAlbum;

NS_ASSUME_NONNULL_BEGIN

@interface NLAlbumRepository : NSObject

/// 查询所有已收藏的专辑。
/// - Returns: 专辑数组，按内部约定的排序返回。
+ (NSArray<NLAlbum *> *)allLikedAlbums;
/// 设置某个专辑的收藏状态。
/// - Parameters:
///   - album: 目标专辑。
///   - liked: YES 表示收藏，NO 表示取消收藏。
/// - Returns: 操作是否成功。
+ (BOOL)setAlbum:(NLAlbum *)album liked:(BOOL)liked;
/// 判断专辑是否已被收藏。
/// - Parameter albumId: 专辑唯一标识。
/// - Returns: 若专辑已被收藏则为 YES。
+ (BOOL)isAlbumLiked:(NSString *)albumId;

@end

NS_ASSUME_NONNULL_END
