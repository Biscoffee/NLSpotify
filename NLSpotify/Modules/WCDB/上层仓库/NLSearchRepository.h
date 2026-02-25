//
//  NLSearchRepository.h
//  NLSpotify
//
//  Created by 吴桐 on 2026/2/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NLSearchRecord;

@interface NLSearchRepository : NSObject

/// 1. 新增/更新一条搜索记录 (自动更新时间戳)
+ (BOOL)addSearchRecord:(NSString *)keyword;

/// 2. 获取搜索历史 (按时间倒序排列，比如最多取前 20 条)
+ (NSArray<NLSearchRecord *> *)allSearchRecords;

/// 3. 清空所有搜索历史
+ (BOOL)clearAllSearchRecords;

/// 4. 删除单条搜索历史
+ (BOOL)removeSearchRecord:(NSString *)keyword;

@end

NS_ASSUME_NONNULL_END
