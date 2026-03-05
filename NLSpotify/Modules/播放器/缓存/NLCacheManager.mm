//
//  NLCacheManager.m
//  NLSpotify
//
//  Created by 吴桐 on 2026/2/26.
//
/*
 tmp文件用于
 */
#import "NLCacheManager.h"
#import "NLAudioCacheInfo+WCDB.h"
#import "NLDataBaseManager.h"
#import <CommonCrypto/CommonDigest.h>
//支持pwrite
#import "fcntl.h"
#import "unistd.h"

static NSString * const kAudioCacheTableName = @"AudioCacheInfoTable";

NSNotificationName const NLCacheManagerDidFinishCachingNotification = @"NLCacheManagerDidFinishCachingNotification";

static const long long kAudioCacheMaxSize = 500 * 1024 * 1024; // 500MB

@interface NLCacheManager ()
// @property (nonatomic, strong) NSLock *fileLock;
@property (nonatomic, copy) NSString *cacheDirectory;
@end

@implementation NLCacheManager

+ (instancetype)sharedManager {
    static NLCacheManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[NLCacheManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
      //  _fileLock = [[NSLock alloc] init];
        // 初始化存放音频的沙盒目录，先找到存缓存的文件夹，然后把这个路径存到_cacheDire属性
        NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        _cacheDirectory = [cacheDir stringByAppendingPathComponent:@"NLAudioCache"];

        BOOL isDir = NO;
        if (![[NSFileManager defaultManager] fileExistsAtPath:_cacheDirectory isDirectory:&isDir]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:_cacheDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        }
        WCTDatabase *db = [NLDataBaseManager sharedManager].database;
        [db createTable:kAudioCacheTableName withClass:NLAudioCacheInfo.class];
    }
    return self;
}

#pragma mark - MD5

- (NSString *)md5StringFromURL:(NSURL *)url {
    if (!url || url.absoluteString.length == 0) return @"";
    /*
     MD5算法把URL变为纯数字字符串，因为URL中含有特殊符号不能作为文件名，因此需要转换
     */
    const char *str = url.absoluteString.UTF8String;
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str,
           (CC_LONG)strlen(str),
           result);
    NSMutableString *md5 = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [md5 appendFormat:@"%02x", result[i]];
    }
    return md5;
}

#pragma mark - Path 和 工具方法

/*
 如果歌曲没下载完，那么就是tmp，下载完变为mp3
 */
- (NSString *)tempFilePathForURL:(NSURL *)url {
    return [self.cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.tmp", [self md5StringFromURL:url]]];
}

- (NSString *)cacheFilePathForURL:(NSURL *)url {
    return [self.cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3", [self md5StringFromURL:url]]];
}

- (BOOL)isFullyCachedForURL:(NSURL *)url {
    return [[NSFileManager defaultManager] fileExistsAtPath:[self cacheFilePathForURL:url]];
}

- (long long)totalLengthForURL:(NSURL *)url {
    NLAudioCacheInfo *info = [[[NLDataBaseManager sharedManager] database] getObjectOfClass:NLAudioCacheInfo.class fromTable:kAudioCacheTableName where:NLAudioCacheInfo.urlMD5 == [self md5StringFromURL:url]];
    return info ? info.totalLength : 0;
}

- (float)cacheProgressForURL:(NSURL *)url {
    if (!url) return 0.f;
    if ([self isFullyCachedForURL:url]) return 1.0f;
    long long total = [self totalLengthForURL:url];
    if (total <= 0) return 0.f;
    NSArray<NSValue *> *ranges = [self cachedRangesForURL:url];
    if (ranges.count == 0) return 0.f;
    unsigned long long covered = 0;
    for (NSValue *v in ranges) {
        covered += v.rangeValue.length;
    }
    float p = (float)((double)covered / (double)total);
    if (p > 1.0f) {
        p = 1.0f;
    } else if (p < 0.0f) {
        p = 0.0f;
    }
    return p > 1.f ? 1.f : p;
}

- (NSTimeInterval)lastAccessTimeForFullyCachedURL:(NSURL *)url {
    if (!url || ![self isFullyCachedForURL:url]) return 0;
    NSString *md5 = [self md5StringFromURL:url];
    NLAudioCacheInfo *info = [[[NLDataBaseManager sharedManager] database] getObjectOfClass:NLAudioCacheInfo.class fromTable:kAudioCacheTableName where:NLAudioCacheInfo.urlMD5 == md5];
    return info ? info.lastAccessTime : 0;
}


#pragma mark - GCD 队列

- (dispatch_queue_t)queueForMD5:(NSString *)md5 {
    if (md5.length == 0) return dispatch_get_main_queue();
    static NSMutableDictionary<NSString *, dispatch_queue_t> *fileQueues;
    static dispatch_queue_t dictionaryQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fileQueues = [NSMutableDictionary dictionary];
        dictionaryQueue = dispatch_queue_create("nl.cache.dictionaryQueue", DISPATCH_QUEUE_SERIAL);
    });
    __block dispatch_queue_t targetQueue = nil;
    dispatch_sync(dictionaryQueue, ^{
        targetQueue = fileQueues[md5];
        if (!targetQueue) {
            NSString *queueName = [NSString stringWithFormat:@"nl.cache.file.%@", md5];
            targetQueue = dispatch_queue_create(queueName.UTF8String, DISPATCH_QUEUE_SERIAL);
            fileQueues[md5] = targetQueue;
        }
    });
    return targetQueue;
}


- (void)cacheData:(NSData *)data forURL:(NSURL *)url atOffset:(long long)offset totalLength:(long long)totalLength {
    if (!data || data.length == 0 || !url) return;
    NSString *md5 = [self md5StringFromURL:url];
    // 防频繁查库拦截网。因为Range下载时每秒几十次cacheData，
    static NSMutableSet<NSString *> *ensuredURLs = nil;
    static dispatch_queue_t setQueue = nil;
    static dispatch_once_t onceToken;
    NSData *dataCopy = [data copy];
    dispatch_once(&onceToken, ^{
        ensuredURLs = [NSMutableSet set];
        setQueue = dispatch_queue_create("nl.cache.setQueue", DISPATCH_QUEUE_SERIAL);
    });

    __block BOOL needsEnsureDB = NO;
    dispatch_sync(setQueue, ^{
        if (![ensuredURLs containsObject:md5]) {
            needsEnsureDB = YES;
            if (totalLength > 0) {
                [ensuredURLs addObject:md5];
            }
        }
    });
    // 丢进这首歌专属的
    dispatch_async([self queueForMD5:md5], ^{
        if (needsEnsureDB) {
            WCTDatabase *db = [[NLDataBaseManager sharedManager] database];
            NLAudioCacheInfo *info = [db getObjectOfClass:NLAudioCacheInfo.class fromTable:kAudioCacheTableName where:NLAudioCacheInfo.urlMD5 == md5];
            BOOL isNew = NO;
            if (!info) {
                isNew = YES;
                info = [[NLAudioCacheInfo alloc] init];
                info.urlMD5 = md5;
                info.totalLength = totalLength;
                info.isFinished = NO;
                info.cachedRangesString = @"[]";
            } else if (info.totalLength <= 0 && totalLength > 0) {
                info.totalLength = totalLength;
            }
            info.lastAccessTime = [[NSDate date] timeIntervalSince1970] * 1000;
            [db insertOrReplaceObject:info intoTable:kAudioCacheTableName];
            if (isNew) {
                NSLog(@"[CacheManager] 该歌曲无缓存，建立账本档案 totalLength=%lld", totalLength);
            }
        }
        // 高频落盘
        NSString *tempPath = [self tempFilePathForURL:url];
//        if (![[NSFileManager defaultManager] fileExistsAtPath:tempPath]) {
//            NSString *directory = [tempPath stringByDeletingLastPathComponent];
//            if (![[NSFileManager defaultManager] fileExistsAtPath:directory]) {
//                [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
//            }
//            if (![[NSFileManager defaultManager] createFileAtPath:tempPath contents:nil attributes:nil]) {
//                NSLog(@"[CacheManager] 创建文件失败: %@", tempPath);
//                return;
//            }
//        }
        // C语言内核级IO，直接拿文件描述符，O_WRONLY ：只写 | O_CREAT：没有就创建
        // 0644:UNIX文件权限
        int fd = open([tempPath UTF8String], O_RDWR | O_CREAT, 0644);
        if (fd == -1) {
            NSLog(@"[CacheManager] open 文件失败，错误码：%d", errno);
            return;
        }
        ssize_t writtenBytes = pwrite(fd, dataCopy.bytes, dataCopy.length, offset);
        if (writtenBytes == -1) {
            NSLog(@"[CacheManager] pwrite 写入失败, 错误码: %d", errno);
        }
        if (writtenBytes != data.length) {
            NSLog(@"cache partial write %ld / %lu",(long)writtenBytes,(unsigned long)data.length);
        }
        close(fd);

//        NSFileHandle *handle = [NSFileHandle fileHandleForUpdatingAtPath:tempPath];
//        if (!handle) {
//            NSLog(@"[CacheManager] 无法打开文件句柄: %@", tempPath);
//            return;
//        }
//
//        @try {
//            [handle seekToFileOffset:offset];
//            [handle writeData:data];
//        } @catch (NSException *exception) {
//            NSLog(@"[CacheManager] 写入文件异常: %@", exception);
//        } @finally {
//            [handle closeFile];
//        }
    });
}


- (void)finishCacheForURL:(NSURL *)url {
//    [self.fileLock lock];
//    if (![self cachedRangesCoverFullLengthForURL:url]) {
//        [self.fileLock unlock];
//        return;
//    }
    NSString *md5 = [self md5StringFromURL:url];
    dispatch_async([self queueForMD5:md5], ^{
        NSString *tempPath = [self tempFilePathForURL:url];
        NSString *cachePath = [self cacheFilePathForURL:url];
        NSError *error = nil;
        if ([[NSFileManager defaultManager] fileExistsAtPath:tempPath]) {
            [[NSFileManager defaultManager] moveItemAtPath:tempPath toPath:cachePath error:&error];
        }
        if (!error) {
            NSString *md5 = [self md5StringFromURL:url];
            WCTDatabase *db = [[NLDataBaseManager sharedManager] database];
            NLAudioCacheInfo *info = [db getObjectOfClass:NLAudioCacheInfo.class fromTable:kAudioCacheTableName where:NLAudioCacheInfo.urlMD5 == md5];
            if (info) {
                info.isFinished = YES;
                info.lastAccessTime = [[NSDate date] timeIntervalSince1970] * 1000;
                [db insertOrReplaceObject:info intoTable:kAudioCacheTableName];
            }
            NSLog(@"[缓存] 下载完成，tmp 转 mp3，该歌曲已完全在缓存中 url=%@", url.absoluteString ?: @"");
            NSURL *notifyURL = [url copy];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:NLCacheManagerDidFinishCachingNotification object:self userInfo:notifyURL ? @{ @"url": notifyURL } : nil];
            });
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                [self cleanCacheWithMaxSize:kAudioCacheMaxSize];
            });
        }
    });

  //  [self.fileLock unlock];
   // [self cleanCacheWithMaxSize:kAudioCacheMaxSize];
}


- (void)mergeAndSaveSessionRanges:(NSArray<NSValue *> *)sessionRanges forURL:(NSURL *)url {
    if (!url || sessionRanges.count == 0) return;
    NSString *md5 = [self md5StringFromURL:url];
    __weak typeof(self) weakSelf = self;

    dispatch_async([self queueForMD5:md5], ^{
        WCTDatabase *db = [[NLDataBaseManager sharedManager] database];
        NLAudioCacheInfo *info = [db getObjectOfClass:NLAudioCacheInfo.class fromTable:kAudioCacheTableName where:NLAudioCacheInfo.urlMD5 == md5];
        if (!info) return;

        NSMutableArray<NSValue *> *existing = [[self parseRangesFromString:info.cachedRangesString] mutableCopy];
        [existing addObjectsFromArray:sessionRanges];
        NSArray<NSValue *> *merged = [self mergeRanges:existing];

        info.cachedRangesString = [self stringFromRanges:merged];
        info.lastAccessTime = [[NSDate date] timeIntervalSince1970] * 1000;
        [db insertOrReplaceObject:info intoTable:kAudioCacheTableName];

        // 合并后再判断是否已覆盖整首，在主线回调中执行 finishCacheForURL（内部再入队）
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf && [strongSelf cachedRangesCoverFullLengthForURL:url]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf finishCacheForURL:url];
            });
        }
    });
}

- (BOOL)cachedRangesCoverFullLengthForURL:(NSURL *)url {
    if ([self isFullyCachedForURL:url]) return NO;
    long long total = [self totalLengthForURL:url];
    if (total <= 0) return NO;

    NSArray<NSValue *> *ranges = [self cachedRangesForURL:url];
    if (ranges.count == 0) return NO;
    NSArray<NSValue *> *sorted = [ranges sortedArrayUsingComparator:^NSComparisonResult(NSValue *a, NSValue *b) {
        if (a.rangeValue.location < b.rangeValue.location) return NSOrderedAscending;
        if (a.rangeValue.location > b.rangeValue.location) return NSOrderedDescending;
        return NSOrderedSame;
    }];
    if (sorted.firstObject.rangeValue.location != 0)  return NO;
    long long pos = 0;
    for (NSValue *v in sorted) {
        NSRange r = v.rangeValue;
        if ((long long)r.location > pos) return NO;
        pos = (long long)NSMaxRange(r);
    }
    return pos >= total;
}

#pragma mark - LRU缓存

- (void)cleanCacheWithMaxSize:(long long)maxSize {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        WCTDatabase *db = [[NLDataBaseManager sharedManager] database];
        NSArray<NLAudioCacheInfo *> *allInfos = [db getObjectsOfClass:NLAudioCacheInfo.class fromTable:kAudioCacheTableName];
        long long currentSize = 0;
        for (NLAudioCacheInfo *info in allInfos) {
            currentSize += info.totalLength;
        }
        if (currentSize <= maxSize) {
            return;
        }
        NSLog(@"[缓存清理] 账本总计 %lld MB, 超出限制 %lld MB，触发 LRU 清理缓存机制", currentSize / 1024 / 1024, maxSize / 1024 / 1024);

        // 按最后访问时间排序，最老的在前面
        NSArray<NLAudioCacheInfo *> *sortedInfos = [allInfos sortedArrayUsingComparator:^NSComparisonResult(NLAudioCacheInfo *obj1, NLAudioCacheInfo *obj2) {
            if (obj1.lastAccessTime < obj2.lastAccessTime) return NSOrderedAscending;
            if (obj1.lastAccessTime > obj2.lastAccessTime) return NSOrderedDescending;
            return NSOrderedSame;
        }];
        // 开始清理老旧文件
        for (NLAudioCacheInfo *info in sortedInfos) {
            NSString *md5 = info.urlMD5;
            // 在它的专属队列里
            dispatch_sync([self queueForMD5:md5], ^{
                NSString *tmpPath = [self.cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.tmp", md5]];
                NSString *mp3Path = [self.cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3", md5]];

                BOOL deleted = NO;
                if ([[NSFileManager defaultManager] fileExistsAtPath:mp3Path]) {
                    [[NSFileManager defaultManager] removeItemAtPath:mp3Path error:nil];
                    deleted = YES;
                } else if ([[NSFileManager defaultManager] fileExistsAtPath:tmpPath]) {
                    [[NSFileManager defaultManager] removeItemAtPath:tmpPath error:nil];
                    deleted = YES;
                }
                if (deleted) {
                    [db deleteFromTable:kAudioCacheTableName where:NLAudioCacheInfo.urlMD5 == md5];
                    NSLog(@"[缓存清理] 剔除了老旧文件 %@，释放了 %lld 空间", md5, info.totalLength);
                }
            });
            currentSize -= info.totalLength;
            if (currentSize <= maxSize) break;
        }
    });
}

- (void)clearAllCache {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSFileManager *fm = [NSFileManager defaultManager];
        NSError *err = nil;
        NSArray<NSString *> *contents = [fm contentsOfDirectoryAtPath:self.cacheDirectory error:&err];
        if (err) {
            NSLog(@"[缓存] clearAllCache 列举目录失败: %@", err.localizedDescription);
            return;
        }
        for (NSString *name in contents) {
            NSString *path = [self.cacheDirectory stringByAppendingPathComponent:name];
            [fm removeItemAtPath:path error:nil];
        }
        WCTDatabase *db = [[NLDataBaseManager sharedManager] database];
        [db deleteFromTable:kAudioCacheTableName];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:NLCacheManagerDidFinishCachingNotification object:self];
        });
        NSLog(@"[缓存] 已清空所有缓存");
    });
}

#pragma mark - 算法：Range 的合并与解析

//
- (NSArray<NSValue *> *)mergeRanges:(NSArray<NSValue *> *)ranges {
    if (ranges.count <= 1) return ranges;
    //按起点 (location) 从小到大排序
    NSArray *sortedRanges = [ranges sortedArrayUsingComparator:^NSComparisonResult(NSValue *obj1, NSValue *obj2) {
        NSRange r1 = obj1.rangeValue;
        NSRange r2 = obj2.rangeValue;
        if (r1.location < r2.location) return NSOrderedAscending;
        if (r1.location > r2.location) return NSOrderedDescending;
        return NSOrderedSame;
    }];
    NSMutableArray<NSValue *> *merged = [NSMutableArray array];
    NSRange currentRange = [sortedRanges.firstObject rangeValue];
    for (NSInteger i = 1; i < sortedRanges.count; i++) {
        NSRange nextRange = [sortedRanges[i] rangeValue];
        // 如果 current 和 next 有重叠或刚好首尾相连 (location <= MaxRange)
        if (nextRange.location <= NSMaxRange(currentRange)) {
            long long maxBoundary = MAX(NSMaxRange(currentRange), NSMaxRange(nextRange));
            currentRange.length = maxBoundary - currentRange.location;
        } else {
            [merged addObject:[NSValue valueWithRange:currentRange]];
            currentRange = nextRange;
        }
    }
    [merged addObject:[NSValue valueWithRange:currentRange]];
    return merged;
}

- (NSArray<NSValue *> *)cachedRangesForURL:(NSURL *)url {
    NSString *md5 = [self md5StringFromURL:url];
    NLAudioCacheInfo *info = [[[NLDataBaseManager sharedManager] database] getObjectOfClass:NLAudioCacheInfo.class fromTable:kAudioCacheTableName where:NLAudioCacheInfo.urlMD5 == md5];
    if (!info) return @[];
    return [self parseRangesFromString:info.cachedRangesString];
}

// JSON String -> NSArray<NSValue *>
- (NSArray<NSValue *> *)parseRangesFromString:(NSString *)string {
    if (string.length == 0) return @[];
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *arr = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSMutableArray *res = [NSMutableArray array];
    for (NSDictionary *dict in arr) {
        NSRange r = NSMakeRange([dict[@"loc"] longLongValue], [dict[@"len"] unsignedIntegerValue]);
        [res addObject:[NSValue valueWithRange:r]];
    }
    return res;
}

// NSArray<NSValue *> -> JSON String
- (NSString *)stringFromRanges:(NSArray<NSValue *> *)ranges {
    NSMutableArray *arr = [NSMutableArray array];
    for (NSValue *val in ranges) {
        NSRange r = val.rangeValue;
        [arr addObject:@{@"loc": @(r.location), @"len": @(r.length)}];
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:arr options:0 error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end

#pragma mark - 一些废弃方法

/*  该方法已被废弃，加锁后多个URL写入相互阻塞
- (void)writeData:(NSData *)data toTempFileForURL:(NSURL *)url atOffset:(long long)offset {
    if (!data || data.length == 0 || !url) return;
    [self.fileLock lock];
    NSString *tempPath = [self tempFilePathForURL:url];
    if (![[NSFileManager defaultManager] fileExistsAtPath:tempPath]) {
        [[NSFileManager defaultManager] createFileAtPath:tempPath contents:nil attributes:nil];
    }
    NSFileHandle *handle = [NSFileHandle fileHandleForUpdatingAtPath:tempPath];
    @try {
        [handle seekToFileOffset:offset];
        [handle writeData:data];
    } @catch (NSException *exception) {
        NSLog(@"写入文件异常: %@", exception);
    } @finally {
        [handle closeFile];
    }
    [self.fileLock unlock];
}
*/
//
//- (void)writeData:(NSData *)data toTempFileForURL:(NSURL *)url atOffset:(long long)offset {
//    if (!data || data.length == 0 || !url) return;
//    NSString *md5 = [self md5StringFromURL:url];
//    /*
//     fileLocks       → 存储每个文件的锁，保护具体的文件，保证同一个文件只能一个线程写
//     onceToken       → 确保只初始化一次
//     dictionaryLock  → 保护 fileLocks 字典，播放器可能同时下载多个Range 即并发写入，通过字典键值对实现一个线程一个文件一个锁。同一个文件穿行 不同文件并发
//     */
//    static NSMutableDictionary<NSString *, NSLock *> *fileLocks = nil;
//    //static NSMutableDictionary<NSString *, dispatch_queue_t> *fileQueue = nil;
//    /*  该字典结构如下：
//     fileLocks
//     {
//        md5(url1) : lock1
//        md5(url2) : lock2
//        md5(url3) : lock3
//     }，因为MutableDic非线程安全，防止多个线程同时操作fileLock。
//     */
//    static dispatch_once_t onceToken;
//    static NSLock *dictionaryLock = nil;
////    static dispatch_once_t onceToken;
////    static dispatch_queue_t dictionaryQueue;
//
//    dispatch_once(&onceToken, ^{
//        fileLocks = [NSMutableDictionary dictionary];
//        dictionaryLock = [[NSLock alloc] init];
////        fileQueue = [NSMutableDictionary dictionary];
////        dictionaryQueue = dispatch_queue_create("nl.cache.dcitionary", DISPATCH_QUEUE_SERIAL);
//    });
//    // 每个 URL 有自己独立的文件锁，dictionaryLock只锁获取锁的过程而并非
//    NSLock *fileLock = nil;
//    [dictionaryLock lock];
//    fileLock = fileLocks[md5];
//    if (!fileLock) {
//        fileLock = [[NSLock alloc] init];
//        fileLocks[md5] = fileLock;
//    }
//    [dictionaryLock unlock];
//
//    [fileLock lock];
//    NSString *tempPath = [self tempFilePathForURL:url];
//    if (![[NSFileManager defaultManager] fileExistsAtPath:tempPath]) {
//        // 创建文件时确保目录存在
//        NSString *directory = [tempPath stringByDeletingLastPathComponent];
//        if (![[NSFileManager defaultManager] fileExistsAtPath:directory]) {
//            [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
//        }
//        if (![[NSFileManager defaultManager] createFileAtPath:tempPath contents:nil attributes:nil]) {
//            NSLog(@"创建文件失败: %@", tempPath);
//            [fileLock unlock];
//            return;
//        }
//    }
//    //  打开文件句柄 以读写方式
//    NSFileHandle *handle = [NSFileHandle fileHandleForUpdatingAtPath:tempPath];
//    if (!handle) {
//        NSLog(@"无法打开文件句柄: %@", tempPath);
//        [fileLock unlock];
//        return;
//    }
//    @try {
//        [handle seekToFileOffset:offset];
//        [handle writeData:data];
//    } @catch (NSException *exception) {
//        NSLog(@"写入文件异常: %@, 文件: %@", exception, tempPath);
//    } @finally {
//        [handle closeFile];
//    }
//    [fileLock unlock];
//}

/*
- (void)writeData:(NSData *)data toTempFileForURL:(NSURL *)url atOffset:(long long)offset {
    if (!data || data.length == 0 || !url) return;

    NSString *md5 = [self md5StringFromURL:url];

    // 静态变量：管理队列的字典，和保护字典的串行队列
    static NSMutableDictionary<NSString *, dispatch_queue_t> *fileQueues = nil;
    static dispatch_queue_t dictionaryQueue = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        fileQueues = [NSMutableDictionary dictionary];
        // 用来保护 NSMutableDictionary 读写的短命串行队列
        dictionaryQueue = dispatch_queue_create("nl.cache.dictionaryQueue", DISPATCH_QUEUE_SERIAL);
    });

    // 从字典中获取（或创建）这首歌专属的 I/O 串行队列
    __block dispatch_queue_t targetFileQueue = nil; //通过__block捕获内部的queue
    dispatch_sync(dictionaryQueue, ^{
        targetFileQueue = fileQueues[md5];
        if (!targetFileQueue) {
            // 给这首歌创建一个专属的串行队列
            NSString *queueName = [NSString stringWithFormat:@"nl.cache.file.%@", md5];
            targetFileQueue = dispatch_queue_create(queueName.UTF8String, DISPATCH_QUEUE_SERIAL);
            fileQueues[md5] = targetFileQueue;
        }
    });

    // 把文件写入的脏活，异步扔给这首歌专属的队列去排队执行！
    // 这样网络线程瞬间解放，不阻塞
    dispatch_async(targetFileQueue, ^{
        NSString *tempPath = [self tempFilePathForURL:url];

        if (![[NSFileManager defaultManager] fileExistsAtPath:tempPath]) {
            NSString *directory = [tempPath stringByDeletingLastPathComponent];
            if (![[NSFileManager defaultManager] fileExistsAtPath:directory]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:directory
                                          withIntermediateDirectories:YES
                                                           attributes:nil
                                                                error:nil];
            }
            if (![[NSFileManager defaultManager] createFileAtPath:tempPath contents:nil attributes:nil]) {
                NSLog(@"[CacheManager] 创建文件失败: %@", tempPath);
                return;
            }
        }

        NSFileHandle *handle = [NSFileHandle fileHandleForUpdatingAtPath:tempPath];
        if (!handle) {
            NSLog(@"[CacheManager] 无法打开文件句柄: %@", tempPath);
            return;
        }
        @try {
            [handle seekToFileOffset:offset];
            [handle writeData:data];
        } @catch (NSException *exception) {
            NSLog(@"[CacheManager] 写入文件异常: %@", exception);
        } @finally {
            [handle closeFile];
        }
    });
}

- (void)ensureCacheInfoForURL:(NSURL *)url totalLength:(long long)totalLength {
    if (!url || totalLength <= 0) return;
    [self.fileLock lock];
    NSString *md5 = [self md5StringFromURL:url];
    WCTDatabase *db = [[NLDataBaseManager sharedManager] database];
    NLAudioCacheInfo *info = [db getObjectOfClass:NLAudioCacheInfo.class fromTable:kAudioCacheTableName where:NLAudioCacheInfo.urlMD5 == md5];
    BOOL isNew = NO;
    if (!info) {
        isNew = YES;
        info = [[NLAudioCacheInfo alloc] init];
        info.urlMD5 = md5;
        info.totalLength = totalLength;
        info.isFinished = NO;
        info.cachedRangesString = @"[]";
    } else if (info.totalLength <= 0) {
        info.totalLength = totalLength;
    }
    info.lastAccessTime = [[NSDate date] timeIntervalSince1970] * 1000;
    [db insertOrReplaceObject:info intoTable:kAudioCacheTableName];
    [self.fileLock unlock];
    if (isNew) {
        NSLog(@"[缓存] 该歌曲无缓存，建立缓存信息 totalLength=%lld url=%@", totalLength, url.absoluteString ?: @"");
    }
}
 */
