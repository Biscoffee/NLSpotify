//
//  NLDownloadManager.m
//  NLSpotify
//

#import "NLDownloadManager.h"
#import "NLCacheManager.h"
#import "NLDownloadItem.h"
#import "NLDownloadRepository.h"
#import "NLSongRepository.h"
#import "NLSongService.h"
#import "NLSong.h"

NSNotificationName const NLDownloadManagerDidUpdateNotification = @"NLDownloadManagerDidUpdateNotification";

@interface NLDownloadManager () <NSURLSessionDataDelegate>
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSMutableDictionary<NSString *, id> *> *taskContextMap;
@property (nonatomic, strong) NSLock *lock;
@end

@implementation NLDownloadManager

+ (instancetype)sharedManager {
    static NLDownloadManager *m;
    static dispatch_once_t once;
    dispatch_once(&once, ^{ m = [[NLDownloadManager alloc] init]; });
    return m;
}

- (instancetype)init {
    if (self = [super init]) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
        _taskContextMap = [NSMutableDictionary dictionary];
        _lock = [[NSLock alloc] init];
    }
    return self;
}

- (void)addDownloadForSong:(NLSong *)song {
    if (!song || !song.songId.length) return;
    if ([NLDownloadRepository downloadItemForSongId:song.songId] != nil) {
        return; // 已在队列
    }
    if (song.playURL) {
        [self startDownloadWithSong:song];
        return;
    }
    __weak typeof(self) w = self;
    [[NLSongService sharedService] fetchPlayableURLWithSongId:song.songId
        success:^(NSURL *playURL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                song.playURL = playURL;
                [w startDownloadWithSong:song];
            });
        }
        failure:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"[下载] 获取播放链接失败 %@", error.localizedDescription);
            });
        }];
}

- (void)startDownloadWithSong:(NLSong *)song {
    if (!song.playURL) return;
    BOOL ok = [NLDownloadRepository addDownloadItemWithSong:song status:@"downloading"];
    if (!ok) return;
    [[NSNotificationCenter defaultCenter] postNotificationName:NLDownloadManagerDidUpdateNotification object:self];

    NSURL *url = song.playURL;
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setValue:@"bytes=0-" forHTTPHeaderField:@"Range"];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:req];
    [self.lock lock];
    NSMutableDictionary *ctx = [NSMutableDictionary dictionary];
    ctx[@"url"] = url;
    ctx[@"songId"] = song.songId;
    ctx[@"currentOffset"] = @(0LL);
    ctx[@"totalLength"] = @(0LL);
    ctx[@"sessionRanges"] = [NSMutableArray array];
    self.taskContextMap[@(task.taskIdentifier)] = ctx;
    [self.lock unlock];
    [task resume];
}

- (BOOL)isDownloadingSongId:(NSString *)songId {
    if (!songId.length) return NO;
    [self.lock lock];
    __block BOOL found = NO;
    [self.taskContextMap enumerateKeysAndObjectsUsingBlock:^(NSNumber *k, NSMutableDictionary *ctx, BOOL *stop) {
        if ([ctx[@"songId"] isEqualToString:songId]) { found = YES; *stop = YES; }
    }];
    [self.lock unlock];
    return found;
}

- (void)cancelAllDownloads {
    __weak typeof(self) w = self;
    [self.session getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> *dataTasks, NSArray<NSURLSessionUploadTask *> *uploadTasks, NSArray<NSURLSessionDownloadTask *> *downloadTasks) {
        for (NSURLSessionTask *t in dataTasks) {
            [t cancel];
        }
        [w.lock lock];
        [w.taskContextMap removeAllObjects];
        [w.lock unlock];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:NLDownloadManagerDidUpdateNotification object:w];
        });
    }];
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    NSHTTPURLResponse *http = (NSHTTPURLResponse *)response;
    long long total = http.expectedContentLength;
    NSString *contentRange = http.allHeaderFields[@"Content-Range"];
    if (contentRange.length > 0) {
        NSArray *parts = [contentRange componentsSeparatedByString:@"/"];
        if (parts.count == 2) total = [parts.lastObject longLongValue];
    }
    [self.lock lock];
    NSMutableDictionary *ctx = self.taskContextMap[@(dataTask.taskIdentifier)];
    [self.lock unlock];
    if (ctx) ctx[@"totalLength"] = @(total);
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [self.lock lock];
    NSMutableDictionary *ctx = self.taskContextMap[@(dataTask.taskIdentifier)];
    [self.lock unlock];
    NSURL *url = ctx[@"url"];
    if (!url || data.length == 0) return;
    long long offset = [ctx[@"currentOffset"] longLongValue];
    long long total = [ctx[@"totalLength"] longLongValue];
    [[NLCacheManager sharedManager] cacheData:data forURL:url atOffset:offset totalLength:total];
    NSMutableArray<NSValue *> *ranges = ctx[@"sessionRanges"];
    if ([ranges isKindOfClass:[NSMutableArray class]]) {
        [ranges addObject:[NSValue valueWithRange:NSMakeRange((NSUInteger)offset, data.length)]];
    }
    ctx[@"currentOffset"] = @(offset + (long long)data.length);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    [self.lock lock];
    NSMutableDictionary *ctx = self.taskContextMap[@(task.taskIdentifier)];
    [self.taskContextMap removeObjectForKey:@(task.taskIdentifier)];
    [self.lock unlock];
    NSURL *url = ctx[@"url"];
    NSString *songId = ctx[@"songId"];
    NSArray *ranges = ctx[@"sessionRanges"];
    if (error && error.code != NSURLErrorCancelled) {
        NSLog(@"[下载] 失败 %@", error.localizedDescription);
        [[NSNotificationCenter defaultCenter] postNotificationName:NLDownloadManagerDidUpdateNotification object:self];
        return;
    }
    if (!url || !ranges.count) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NLDownloadManagerDidUpdateNotification object:self];
        return;
    }
    [[NLCacheManager sharedManager] mergeAndSaveSessionRanges:ranges forURL:url];
    if ([[NLCacheManager sharedManager] cachedRangesCoverFullLengthForURL:url]) {
        [[NLCacheManager sharedManager] finishCacheForURL:url];
    }
    [NLDownloadRepository updateStatus:@"completed" forSongId:songId];
    NLDownloadItem *item = [NLDownloadRepository downloadItemForSongId:songId];
    if (item) {
        NSURL *coverURL = item.coverURLString.length ? [NSURL URLWithString:item.coverURLString] : nil;
        NLSong *s = [[NLSong alloc] initWithId:item.songId title:item.title ?: @"" artist:item.artist ?: @"" coverURL:coverURL];
        s.playURL = url;
        [NLSongRepository addDownloadedSong:s];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NLDownloadManagerDidUpdateNotification object:self];
}

@end
