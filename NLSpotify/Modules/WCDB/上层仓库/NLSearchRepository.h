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

+ (BOOL)addSearchRecord:(NSString *)keyword;

+ (NSArray<NLSearchRecord *> *)allSearchRecords;

+ (BOOL)clearAllSearchRecords;

+ (BOOL)removeSearchRecord:(NSString *)keyword;

@end

NS_ASSUME_NONNULL_END
