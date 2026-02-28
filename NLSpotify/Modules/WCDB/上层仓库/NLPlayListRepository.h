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

// 创建/更新一个歌单
+ (BOOL)savePlayList:(NLPlayList *)playList;

+ (BOOL)deletePlayList:(NSString *)playListId;
+ (NSArray<NLPlayList *> *)allUserCreatedPlayLists;
+ (NSArray<NLPlayList *> *)allLikedPlayLists;

// 将歌单标记为「自建」或「收藏」
+ (BOOL)markPlayList:(NLPlayList *)playList userCreated:(BOOL)isUserCreated;

/// 标记/取消标记某个歌单为「收藏歌单」
+ (BOOL)setPlayList:(NLPlayList *)playList liked:(BOOL)liked;

+ (BOOL)isPlayListLiked:(NSString *)playListId;

+ (BOOL)addSong:(NLSong *)song toPlayList:(NSString *)playListId;
+ (BOOL)removeSong:(NSString *)songId fromPlayList:(NSString *)playListId;


+ (NSArray<NLSong *> *)songsInPlayList:(NSString *)playListId;
+ (nullable NLPlayList *)createUserPlayListWithName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
