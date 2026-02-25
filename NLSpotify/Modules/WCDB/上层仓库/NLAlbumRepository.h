//
//  NLAlbumRepository.h
//  NLSpotify
//
//  收藏专辑的本地持久化（WCDB）
//

#import <Foundation/Foundation.h>

@class NLAlbum;

NS_ASSUME_NONNULL_BEGIN

@interface NLAlbumRepository : NSObject

/// 全部收藏的专辑（按收藏时间倒序）
+ (NSArray<NLAlbum *> *)allLikedAlbums;

/// 收藏/取消收藏专辑
+ (BOOL)setAlbum:(NLAlbum *)album liked:(BOOL)liked;

/// 是否已收藏该专辑
+ (BOOL)isAlbumLiked:(NSString *)albumId;

@end

NS_ASSUME_NONNULL_END
