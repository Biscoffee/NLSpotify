//
//  NLPlayListModel.h
//  NLSpotify
//
//  Created by 吴桐 on 2026/1/12.
//

//每一个歌单的model
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NLHeaderModel : NSObject

@property (nonatomic, assign) NSInteger playlistId;
@property (nonatomic, copy) NSString *name;          // 歌单名
@property (nonatomic, copy) NSString *coverUrl;      // 歌单封面
@property (nonatomic, copy) NSString *desc;          // 描述
@property (nonatomic, copy) NSString *creatorName;   // 创建者昵称
@property (nonatomic, copy) NSString *creatorAvatar; // 创建者头像

@end

NS_ASSUME_NONNULL_END
