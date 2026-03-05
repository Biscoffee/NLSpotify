//
//  NLDataBaseManager.m
//  NLSpotify
//
//  Created by 吴桐 on 2026/2/23.
//

#import "NLDataBaseManager.h"
#import "NLSong+WCDB.h"

static NSString * const kHistoryTableName = @"PlaybackHistoryTable";

@interface NLDataBaseManager ()

@property (nonatomic, strong, readwrite) WCTDatabase *database;

@end

@implementation NLDataBaseManager

+ (instancetype)sharedManager {
    static NLDataBaseManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[NLDataBaseManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupDatabase];
    }
    return self;
}

- (void)setupDatabase {
    //获取沙盒 Document 目录路径
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    //拼接数据库文件的完整路径
    NSString *dbPath = [documentPath stringByAppendingPathComponent:@"NLSpotify_v2.sqlite"];
    self.database = [[WCTDatabase alloc] initWithPath:dbPath];
    if ([self.database canOpen]) {
        BOOL result = [self.database createTable:kHistoryTableName withClass:NLSong.class];
        if (result) {
            NSLog(@"数据库开启成功，表创建完成");
            NSLog(@"数据库沙盒路径: %@", dbPath);
        } else {
            NSLog(@"WCDB 建表失败: %@", self.database.error);
        }
    } else {
        NSLog(@"WCDB 数据库打开失败: %@", self.database.error);
    }
}

@end
