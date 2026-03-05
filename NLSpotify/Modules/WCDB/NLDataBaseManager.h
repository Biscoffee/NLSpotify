//
//  NLDataBaseManager.h
//  NLSpotify
//
//  Created by 吴桐 on 2026/2/23.
//

#import <Foundation/Foundation.h>

@class WCTDatabase;

NS_ASSUME_NONNULL_BEGIN

@interface NLDataBaseManager : NSObject

/// 全局数据库管理单例。
/// - Returns: 全局共享的 `NLDataBaseManager` 实例。
+ (instancetype)sharedManager;

/// 底层 WCDB 数据库实例。
/// - Discussion: 所有仓库类应通过此属性获取同一数据库连接。
@property (nonatomic, readonly) WCTDatabase *database;

@end

NS_ASSUME_NONNULL_END
