//
//  NLPlayList+WCDB.h
//  NLSpotify
//
//  Created by 吴桐 on 2026/2/23.
//

#import "NLPlayList.h"
#import <WCDBObjc/WCDBObjc.h>

NS_ASSUME_NONNULL_BEGIN
@interface NLPlayList (WCDB) <WCTTableCoding>
WCDB_PROPERTY(playlistId)
WCDB_PROPERTY(name)
WCDB_PROPERTY(coverURL)
WCDB_PROPERTY(isUserCreated)
WCDB_PROPERTY(createTime)
@end
NS_ASSUME_NONNULL_END
