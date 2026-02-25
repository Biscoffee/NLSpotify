//
//  NLPlayList.h
//  NLSpotify
//
//  Created by 吴桐 on 2026/2/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NLPlayList : NSObject

@property (nonatomic, copy) NSString *playlistId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *coverURL;  
@property (nonatomic, assign) BOOL isUserCreated; // YES: 自建歌单，NO: 收藏的网易云歌单
@property (nonatomic, assign) NSTimeInterval createTime;

- (instancetype)initWithId:(NSString *)playlistId name:(NSString *)name isUserCreated:(BOOL)isUserCreated;

@end

NS_ASSUME_NONNULL_END
