//
//  NLSearchRepository.m
//  NLSpotify
//
//  Created by 吴桐 on 2026/2/23.
//

#import "NLSearchRepository.h"
#import "NLDataBaseManager.h"
#import "NLSearchRecord+WCDB.h"

static NSString * const kSearchHistoryTableName = @"SearchHistoryTable";

@implementation NLSearchRepository

+ (WCTDatabase *)safeDatabase {
    WCTDatabase *db = [NLDataBaseManager sharedManager].database;
    [db createTable:kSearchHistoryTableName withClass:NLSearchRecord.class];
    return db;
}

+ (BOOL)addSearchRecord:(NSString *)keyword {
    if (keyword.length == 0) return NO;

    NLSearchRecord *record = [[NLSearchRecord alloc] initWithKeyword:keyword];

    // 2. ✨ v2 API 写入：因为我们设置了 keyword 为主键，
    // 所以同一个词再次搜索时，不会生成两条数据，而是自动刷新它的 timestamp！
    BOOL result = [[self safeDatabase] insertOrReplaceObject:record intoTable:kSearchHistoryTableName];

    if (!result) NSLog(@"❌ 保存搜索记录失败");
    return result;
}

+ (NSArray<NLSearchRecord *> *)allSearchRecords {
    NSArray<NLSearchRecord *> *records = [[self safeDatabase] getObjectsOfClass:NLSearchRecord.class
                                                                      fromTable:kSearchHistoryTableName];

    if (!records || records.count == 0) return @[];
    NSArray *sortedRecords = [records sortedArrayUsingComparator:^NSComparisonResult(NLSearchRecord *obj1, NLSearchRecord *obj2) {
        if (obj1.timestamp > obj2.timestamp) {
            return NSOrderedAscending;  // 降序：时间戳越大的（越新），排在越前面
        } else if (obj1.timestamp < obj2.timestamp) {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
    if (sortedRecords.count > 20) {
        return [sortedRecords subarrayWithRange:NSMakeRange(0, 20)];
    }
    return sortedRecords;
}

+ (BOOL)clearAllSearchRecords {
    BOOL result = [[self safeDatabase] deleteFromTable:kSearchHistoryTableName];

    if (!result) NSLog(@"清空搜索记录失败");
    return result;
}

+ (BOOL)removeSearchRecord:(NSString *)keyword {
    if (keyword.length == 0) return NO;
    BOOL result = [[self safeDatabase] deleteFromTable:kSearchHistoryTableName
                                                 where:NLSearchRecord.keyword == keyword];
    if (!result) NSLog(@"删除单条搜索记录失败");
    return result;
}

@end
