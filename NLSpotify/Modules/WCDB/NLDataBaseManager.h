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

+ (instancetype)sharedManager;

@property (nonatomic, readonly) WCTDatabase *database;

@end

NS_ASSUME_NONNULL_END
