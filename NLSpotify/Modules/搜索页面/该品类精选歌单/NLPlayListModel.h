//
//  NLPlayListModel.h
//  NLSpotify
//
//  Created by 吴桐 on 2026/1/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NLPlaylistModel : NSObject

@property (nonatomic, assign) NSInteger playlistId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *coverImgUrl;
@property (nonatomic, copy) NSString *descriptionText;
@property (nonatomic, assign) NSInteger playCount;
@property (nonatomic, assign) NSInteger subscribedCount;
@property (nonatomic, assign) NSInteger trackCount;
@property (nonatomic, copy) NSString *creatorName;
@property (nonatomic, copy) NSString *creatorAvatarUrl;
@property (nonatomic, copy) NSString *backgroundColorHex;
@property (nonatomic, copy) NSString *previewCoverUrl;
@property (nonatomic, copy) NSArray<NSString *> *tags;

+ (instancetype)playlistWithDictionary:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
