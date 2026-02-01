//
//  NLSong.h
//  NLSpotify
//
//  Created by 吴桐 on 2026/1/18.
//

#import <Foundation/Foundation.h>

@class NLListCellModel;

NS_ASSUME_NONNULL_BEGIN

@interface NLSong : NSObject

@property (nonatomic, copy) NSString *songId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *artist;
@property (nonatomic, strong) NSURL *coverURL;
@property (nonatomic, strong) NSURL *playURL;

/// 便捷构造
- (instancetype)initWithId:(NSString *)songId
                     title:(NSString *)title
                    artist:(NSString *)artist
                  coverURL:(NSURL *)coverURL;

/// 从NLListCellModel创建NLSong（简化转换）
+ (instancetype)songWithListCellModel:(NLListCellModel *)model;

@end
NS_ASSUME_NONNULL_END
