//
//  NLSearchRecord.m
//  NLSpotify
//
//  Created by 吴桐 on 2026/2/23.
//

#import "NLSearchRecord.h"
#import "NLSearchRecord+WCDB.h"

@implementation NLSearchRecord

WCDB_IMPLEMENTATION(NLSearchRecord)
WCDB_SYNTHESIZE(keyword)
WCDB_SYNTHESIZE(timestamp)

// 以 keyword 为主键，这样相同的搜索词会自动覆盖
WCDB_PRIMARY(keyword)

- (instancetype)initWithKeyword:(NSString *)keyword {
    if (self = [super init]) {
        _keyword = keyword;
        _timestamp = [[NSDate date] timeIntervalSince1970];
    }
    return self;
}

@end
