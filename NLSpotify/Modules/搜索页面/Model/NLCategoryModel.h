//
//  NLCategoryModel.h
//  NLSpotify
//
//  Created by 吴桐 on 2026/1/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NLCategoryModel : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) NSString *backgroundColorHex;
@property (nonatomic, copy) NSString *identifier; // 用于路由
@property (nonatomic, copy) NSString *previewCoverUrl; // 该分类第一个歌单封面

+ (NSArray<NLCategoryModel *> *)defaultCategories;

@end

NS_ASSUME_NONNULL_END
