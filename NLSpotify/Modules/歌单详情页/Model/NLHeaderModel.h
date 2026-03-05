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
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *coverUrl;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *creatorName;
@property (nonatomic, copy) NSString *creatorAvatar;
// YES 时不显示简介区域，自建歌单时为NO
@property (nonatomic, assign) BOOL hideDescription;

@end

NS_ASSUME_NONNULL_END
