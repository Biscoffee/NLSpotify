//
//  NLPlayListRepository.h
//  NLSpotify
//
//  Created by 吴桐 on 2026/2/23.
//

#import <Foundation/Foundation.h>

@class NLPlayList;
@class NLSong;

NS_ASSUME_NONNULL_BEGIN

@interface NLPlayListRepository : NSObject

/// 1. 创建/更新一个歌单
+ (BOOL)savePlayList:(NLPlayList *)playList;

/// 2. 删除一个歌单 (会自动清空里面的歌曲关联)
+ (BOOL)deletePlayList:(NSString *)playListId;

/// 3. 查询所有自建歌单
+ (NSArray<NLPlayList *> *)allUserCreatedPlayLists;

/// 4. 查询所有收藏的歌单
+ (NSArray<NLPlayList *> *)allLikedPlayLists;

/// 将歌单标记为「自建」或「收藏」
+ (BOOL)markPlayList:(NLPlayList *)playList userCreated:(BOOL)isUserCreated;

/// 标记/取消标记某个歌单为「收藏歌单」
+ (BOOL)setPlayList:(NLPlayList *)playList liked:(BOOL)liked;

/// 判断某个歌单是否已被收藏
+ (BOOL)isPlayListLiked:(NSString *)playListId;

/// 5. 把一首歌添加到指定歌单
+ (BOOL)addSong:(NLSong *)song toPlayList:(NSString *)playListId;

/// 6. 从指定歌单中移除一首歌
+ (BOOL)removeSong:(NSString *)songId fromPlayList:(NSString *)playListId;

/// 7. 获取某个歌单里的所有歌曲！(终极魔法)
+ (NSArray<NLSong *> *)songsInPlayList:(NSString *)playListId;

/// 8. 创建一个新的自建歌单（仅本地）
+ (nullable NLPlayList *)createUserPlayListWithName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
