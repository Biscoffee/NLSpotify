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

/// 创建或更新一个歌单。
/// - Parameter playList: 需要保存的歌单模型。
/// - Returns: 操作是否成功。
+ (BOOL)savePlayList:(NLPlayList *)playList;

/// 删除指定歌单。
/// - Parameter playListId: 歌单唯一标识。
/// - Returns: 删除是否成功。
+ (BOOL)deletePlayList:(NSString *)playListId;
/// 查询所有用户自建歌单。
/// - Returns: 歌单数组。
+ (NSArray<NLPlayList *> *)allUserCreatedPlayLists;
/// 查询所有已收藏歌单。
/// - Returns: 歌单数组。
+ (NSArray<NLPlayList *> *)allLikedPlayLists;

/// 将歌单标记为「自建」或取消该标记。
/// - Parameters:
///   - playList: 目标歌单。
///   - isUserCreated: YES 表示自建歌单。
/// - Returns: 更新是否成功。
+ (BOOL)markPlayList:(NLPlayList *)playList userCreated:(BOOL)isUserCreated;
/// 设置歌单的收藏状态。
/// - Parameters:
///   - playList: 目标歌单。
///   - liked: YES 表示收藏，NO 表示取消收藏。
/// - Returns: 更新是否成功。
+ (BOOL)setPlayList:(NLPlayList *)playList liked:(BOOL)liked;

/// 判断歌单是否已被收藏。
/// - Parameter playListId: 歌单唯一标识。
/// - Returns: 若已收藏则为 YES。
+ (BOOL)isPlayListLiked:(NSString *)playListId;

/// 向歌单中添加一首歌曲。
/// - Parameters:
///   - song: 歌曲模型。
///   - playListId: 目标歌单唯一标识。
/// - Returns: 添加是否成功。
+ (BOOL)addSong:(NLSong *)song toPlayList:(NSString *)playListId;
/// 从歌单中移除一首歌曲。
/// - Parameters:
///   - songId: 歌曲唯一标识。
///   - playListId: 目标歌单唯一标识。
/// - Returns: 移除是否成功。
+ (BOOL)removeSong:(NSString *)songId fromPlayList:(NSString *)playListId;


/// 查询歌单中的所有歌曲。
/// - Parameter playListId: 歌单唯一标识。
/// - Returns: 歌曲数组。
+ (NSArray<NLSong *> *)songsInPlayList:(NSString *)playListId;
/// 创建一个用户自建歌单。
/// - Parameter name: 歌单名称。
/// - Returns: 创建成功的歌单模型，若失败则为 `nil`。
+ (nullable NLPlayList *)createUserPlayListWithName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
