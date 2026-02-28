//
//  NLResourceLoader.m
//  NLSpotify
//
//  Created by 吴桐 on 2026/2/26.
//

#import "NLResourceLoader.h"
#import "NLCacheManager.h"

@interface NLResourceLoader ()<NSURLSessionDataDelegate>
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, AVAssetResourceLoadingRequest *> *taskRequestMap;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSURLSessionDataTask *> *tasksMap;
@property (nonatomic, strong) NSLock *mapLock;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSMutableDictionary<NSString *, id> *> *taskContextMap;
@end

@implementation NLResourceLoader

- (id)init {
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
            _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
        _tasksMap = [NSMutableDictionary dictionary];
        _taskRequestMap = [NSMutableDictionary dictionary];
        _taskContextMap = [NSMutableDictionary dictionary];
        _mapLock = [[NSLock alloc] init];
    }
    return self;
}

- (void)dealloc {
    [self.session invalidateAndCancel];
}

- (void)invalidateSession {
    [self.session invalidateAndCancel];
}

#pragma mark - ResourceLoader入口

/*
 当AVPlayer遇到我们替换后的协议，因为他不认识，所以出发下面代理方法。我们在这里替换回http，发送请求
 我不需要去手搓复杂的并发请求。如果你只给 AVPlayer 一部分本地数据，然后宣布 finishLoading，AVPlayer 会自动再次向你发起另一个请求要剩下的数据！这是苹果官方的隐藏黑魔法！
 */
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSURL *originURL = self.originURL;
    long long requestedOffset = loadingRequest.dataRequest.requestedOffset;
    NSInteger requestedLength = loadingRequest.dataRequest.requestedLength;

    // 获取历史缓存区间
    NSArray<NSValue *> *cachedRanges = [[NLCacheManager sharedManager] cachedRangesForURL:self.originURL];
    long long dbTotalLength = [[NLCacheManager sharedManager] totalLengthForURL:self.originURL];

    // 如果数据库里有文件总大小，提前给AVPlayer文件信息
    if (dbTotalLength > 0 && loadingRequest.contentInformationRequest) {
        loadingRequest.contentInformationRequest.contentLength = dbTotalLength;
        loadingRequest.contentInformationRequest.contentType = @"public.mp3";
        loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
    }
//  查找缓存命中
    NSRange targetCacheRange = NSMakeRange(NSNotFound, 0); // 用来记录有没有命中本地
    long long nextCacheStart = NSNotFound;                 // 用来记录下一个实心块在哪
    for (NSValue *val in cachedRanges) {
        NSRange r = val.rangeValue;
        // 如果要的数据，刚好落在一个已经缓存的区间里
        if (requestedOffset >= r.location && requestedOffset < NSMaxRange(r)) {
            targetCacheRange = r;
            break;
        }
        // 如果要的数据在空洞里，顺便记一下这个空洞有多大 (下一个实心块起点在哪)
        if (r.location > requestedOffset && (nextCacheStart == NSNotFound || r.location < nextCacheStart)) {
            nextCacheStart = r.location;
        }
    }

// 处理命中：播放器需要的在缓存里面
#pragma mark - 命中本地缓存 (混合请求修复版)

    if (targetCacheRange.location != NSNotFound) {
        long long availableLocalLength = NSMaxRange(targetCacheRange) - requestedOffset;
        NSInteger serveLength = MIN((NSInteger)availableLocalLength, requestedLength);

        BOOL fullyCached = [[NLCacheManager sharedManager] isFullyCachedForURL:originURL];
        NSString *path = fullyCached ?
                         [[NLCacheManager sharedManager] cacheFilePathForURL:originURL] :
                         [[NLCacheManager sharedManager] tempFilePathForURL:originURL];

        int fd = open(path.UTF8String, O_RDONLY);
        if (fd >= 0) {
            void *buffer = malloc(serveLength);
            ssize_t readSize = pread(fd, buffer, serveLength, requestedOffset);

            if (readSize > 0) {
                // 零拷贝喂给播放器
                NSData *data = [NSData dataWithBytesNoCopy:buffer length:readSize freeWhenDone:YES];
                [loadingRequest.dataRequest respondWithData:data];

                if (readSize >= requestedLength) {
                    // 本地存货足够，完全喂饱了，完美下班！
                    if (fullyCached) {
                        NSLog(@"[缓存] 缓存中有全部，不用请求 bytes %lld len=%zd", requestedOffset, readSize);
                    } else {
                        NSLog(@"[缓存] 有部分缓存，本次从本地读取 bytes %lld len=%zd，不发起请求", requestedOffset, readSize);
                    }
                    [loadingRequest finishLoading];
                    close(fd);
                    return YES;
                } else {
                    // 致命陷阱修复！本地只有一点碎肉（比如 2 字节）
                    // 绝对不能调用 finishLoading！而是要修改参数，让代码顺流而下，去触发网络请求！
                    requestedOffset += readSize;
                    requestedLength -= readSize;
                    NSLog(@"[缓存] 本地仅能提供 %zd bytes，修改参数继续向网络乞讨剩余 bytes %lld - ...", readSize, requestedOffset);
                }
            } else {
                free(buffer);
            }
            close(fd);
        }
    }
// 网络请求
    NSInteger fetchLength = requestedLength;
    // 如果后面有个实心块，我们只下到那个实心块的前面，避免重复下载
    if (nextCacheStart != NSNotFound && nextCacheStart < requestedOffset + requestedLength) {
        fetchLength = (NSInteger)(nextCacheStart - requestedOffset);
    }
    if (cachedRanges.count == 0) {
        NSLog(@"[缓存] 无缓存，全部请求 bytes %lld - %lld", requestedOffset, requestedOffset + fetchLength - 1);
    } else {
        NSLog(@"[缓存] 有部分缓存，请求部分 bytes %lld - %lld", requestedOffset, requestedOffset + fetchLength - 1);
    }

    NSURL *realURL = [self realURLFromLoadingRequest:loadingRequest];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:realURL];
    NSString *rangeString = [NSString stringWithFormat:@"bytes=%lld-%lld", requestedOffset, requestedOffset + fetchLength - 1];
    [request setValue:rangeString forHTTPHeaderField:@"Range"];

    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request];
//  保存任务上下文
    [self.mapLock lock];
    self.taskRequestMap[@(task.taskIdentifier)] = loadingRequest;
    self.tasksMap[@(task.taskIdentifier)] = task;
    // 每个任务保存自己的url
    NSMutableDictionary *ctx = [NSMutableDictionary dictionary];
    ctx[@"url"] = originURL;
    ctx[@"startOffset"] = @(requestedOffset);
    ctx[@"currentOffset"] = @(requestedOffset);
    ctx[@"totalLength"] = @(0LL);
    ctx[@"sessionRanges"] = [NSMutableArray array];
    ctx[@"lastLoggedProgressPct"] = @0;
    self.taskContextMap[@(task.taskIdentifier)] = ctx;
    [self.mapLock unlock];

    [task resume];
    return YES;
}

#pragma mark -  辅助方法：替换协议
- (NSURL *)realURLFromLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSURLComponents *components = [NSURLComponents componentsWithURL:loadingRequest.request.URL resolvingAgainstBaseURL:NO];
    components.scheme = self.originURL.scheme; // originURL 是我们在外面传进来的真实链接
    return components.URL;
}

#pragma mark - 取消请求
/*
 当用户点击了下一首，刚才的任务需要停止
 */
- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader
didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    [self.mapLock lock];
    // 遍历字典，找出是哪个 Task 对应这个被取消的请求
    __block NSNumber *targetTaskID = nil;
    [self.taskRequestMap enumerateKeysAndObjectsUsingBlock:^(NSNumber *taskID, AVAssetResourceLoadingRequest *req, BOOL *stop) {
        if (req == loadingRequest) {
            targetTaskID = taskID;
            *stop = YES;
        }
    }];
    //如果找到了，取消网络请求，并从字典里清空
    if (targetTaskID) {
        NSURLSessionDataTask *taskToCancel = self.tasksMap[targetTaskID];
        NSMutableDictionary *ctx = self.taskContextMap[targetTaskID];
        [self.taskRequestMap removeObjectForKey:targetTaskID];
        [self.tasksMap removeObjectForKey:targetTaskID];
        [self.taskContextMap removeObjectForKey:targetTaskID];
        [self.mapLock unlock];
        [taskToCancel cancel];
        NSURL *url = ctx[@"url"];
        if (url && ctx[@"sessionRanges"] && [ctx[@"sessionRanges"] count] > 0) {
            [[NLCacheManager sharedManager] mergeAndSaveSessionRanges:ctx[@"sessionRanges"] forURL:url];
        }
        return;
    }
    [self.mapLock unlock];
}


# pragma mark - Delegate 相关
//  收到服务器响应头 填写文件信息
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSString *contentRange = httpResponse.allHeaderFields[@"Content-Range"];
    long long totalLength = httpResponse.expectedContentLength;
    if (contentRange.length > 0) {
        NSArray *components = [contentRange componentsSeparatedByString:@"/"];
        if (components.count == 2) {
            totalLength = [components.lastObject longLongValue];
        }
    }
    [self.mapLock lock];
    AVAssetResourceLoadingRequest *loadingRequest = self.taskRequestMap[@(dataTask.taskIdentifier)];
    NSMutableDictionary *ctx = self.taskContextMap[@(dataTask.taskIdentifier)];
    [self.mapLock unlock];
    if (ctx) {
        ctx[@"totalLength"] = @(totalLength);
    }
    if (loadingRequest && loadingRequest.contentInformationRequest) {
        loadingRequest.contentInformationRequest.contentLength = totalLength;
        loadingRequest.contentInformationRequest.contentType = @"public.audio"; // 告诉它是通用音频
        loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
    }
    NSURL *url = ctx[@"url"];
    if (url && totalLength > 0) {
        NSLog(@"[缓存] 该歌曲首次拿到总长 totalLength=%lld，已建立缓存信息", totalLength);
    }
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    [self.mapLock lock];
    AVAssetResourceLoadingRequest *loadingRequest = self.taskRequestMap[@(dataTask.taskIdentifier)];
    NSMutableDictionary *ctx = self.taskContextMap[@(dataTask.taskIdentifier)];
    [self.mapLock unlock];
    if (loadingRequest) {
        [loadingRequest.dataRequest respondWithData:data];
    }
    NSURL *url = ctx[@"url"];
    if (ctx && url && data.length > 0) {
        long long currentOffset = [ctx[@"currentOffset"] longLongValue];
        long long totalLength = [ctx[@"totalLength"] longLongValue];
        [[NLCacheManager sharedManager] cacheData:data forURL:url atOffset:currentOffset totalLength:totalLength];
        [self.mapLock lock];
        NSMutableArray<NSValue *> *sessionRanges = ctx[@"sessionRanges"];
        if ([sessionRanges isKindOfClass:[NSMutableArray class]]) {
            [sessionRanges addObject:[NSValue valueWithRange:NSMakeRange((NSUInteger)currentOffset, data.length)]];
        }
        long long newOffset = currentOffset + (long long)data.length;
        ctx[@"currentOffset"] = @(newOffset);
        // 下载进度日志：每 10% 打一次
        if (totalLength > 0) {
            int pct = (int)((newOffset * 100) / totalLength);
            int lastPct = [ctx[@"lastLoggedProgressPct"] intValue];
            if (pct >= lastPct + 10 || pct >= 100) {
                ctx[@"lastLoggedProgressPct"] = @(pct);
                NSLog(@"[缓存] 下载进度 %d%% (%lld / %lld)", pct, newOffset, totalLength);
            }
        }
        [self.mapLock unlock];
    }
}

#pragma mark - 下载结束

- (void)URLSession:(NSURLSession *)session
task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
    [self.mapLock lock];
    NSNumber *taskID = @(task.taskIdentifier);
    NSMutableDictionary *ctx = self.taskContextMap[taskID];
    AVAssetResourceLoadingRequest *loadingRequest = self.taskRequestMap[taskID];
    [self.mapLock unlock];
    if (loadingRequest) {
        if (error && error.code != NSURLErrorCancelled) {
            [loadingRequest finishLoadingWithError:error];
        }
        else {
            [loadingRequest finishLoading];
        }
    }
    NSURL *url = ctx[@"url"];
    NSArray *ranges = ctx[@"sessionRanges"];
    if (url && ranges.count > 0) {
        long long startOffset = [ctx[@"startOffset"] longLongValue];
        unsigned long long rangeLen = 0;
        for (NSValue *v in ranges) rangeLen += v.rangeValue.length;
        NSLog(@"[缓存] 请求完成 offset=%lld length=%llu%@", startOffset, rangeLen, error ? [NSString stringWithFormat:@" error=%@", error.localizedDescription] : @"");
        [[NLCacheManager sharedManager] mergeAndSaveSessionRanges:ranges forURL:url];
        // finishCacheForURL 由 NLCacheManager 在 merge 完成后的回调中根据 cachedRangesCoverFullLengthForURL 调用
    }
    [self.mapLock lock];
    [self.tasksMap removeObjectForKey:taskID];
    [self.taskRequestMap removeObjectForKey:taskID];
    [self.taskContextMap removeObjectForKey:taskID];
    [self.mapLock unlock];
}

- (void)invalidateAndCancelAll {
    [self.mapLock lock];
    NSArray *contexts = [self.taskContextMap allValues];
    [self.taskContextMap removeAllObjects];
    [self.taskRequestMap enumerateKeysAndObjectsUsingBlock:^(NSNumber *taskID, AVAssetResourceLoadingRequest *loadingRequest, BOOL *stop) {
        NSError *cancelError = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:@{NSLocalizedDescriptionKey: @"Resource loader 被销毁"}];
        [loadingRequest finishLoadingWithError:cancelError];
    }];
    [self.tasksMap enumerateKeysAndObjectsUsingBlock:^(NSNumber *taskID, NSURLSessionDataTask *task, BOOL *stop) {
        [task cancel];
    }];
    [self.tasksMap removeAllObjects];
    [self.taskRequestMap removeAllObjects];
    [self.mapLock unlock];

    for (NSMutableDictionary *ctx in contexts) {
        NSURL *url = ctx[@"url"];
        NSArray<NSValue *> *ranges = ctx[@"sessionRanges"];
        if ([url isKindOfClass:[NSURL class]] && [ranges isKindOfClass:[NSArray class]] && ranges.count > 0) {
            [[NLCacheManager sharedManager] mergeAndSaveSessionRanges:ranges forURL:url];
        }
    }
    [self.session invalidateAndCancel];
}

@end
