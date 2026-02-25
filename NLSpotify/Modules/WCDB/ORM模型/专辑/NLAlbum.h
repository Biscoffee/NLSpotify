//
//  NLAlbum.h
//  NLSpotify
//
//  收藏的专辑（网易云专辑 ID + 名称、封面、艺人名）
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NLAlbum : NSObject

@property (nonatomic, copy) NSString *albumId;   // 与 API 专辑 ID 一致，存成字符串
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *coverURL;
@property (nonatomic, copy) NSString *artistName;
@property (nonatomic, assign) NSTimeInterval createTime;

- (instancetype)initWithAlbumId:(NSString *)albumId name:(NSString *)name coverURL:(nullable NSString *)coverURL artistName:(nullable NSString *)artistName;

@end

NS_ASSUME_NONNULL_END
