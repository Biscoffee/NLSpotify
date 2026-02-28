//
//  NLAudioCacheInfo.m
//  NLSpotify
//
//  Created by 吴桐 on 2026/2/26.
//

#import "NLAudioCacheInfo.h"
#import <WCDBObjc/WCDBObjc.h>

@implementation NLAudioCacheInfo

WCDB_IMPLEMENTATION(NLAudioCacheInfo)

WCDB_SYNTHESIZE(urlMD5)
WCDB_SYNTHESIZE(totalLength)
WCDB_SYNTHESIZE(cachedRangesString)
WCDB_SYNTHESIZE(lastAccessTime)
WCDB_SYNTHESIZE(isFinished)

// 将 urlMD5 设置为主键，因为一个 URL 只对应唯一的一份缓存记录
WCDB_PRIMARY(urlMD5)

@end
