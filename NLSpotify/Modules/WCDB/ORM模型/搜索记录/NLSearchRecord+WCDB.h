//
//  NLSearchRecord+WCDB.h
//  NLSpotify
//
//  Created by 吴桐 on 2026/2/23.
//

#import "NLSearchRecord.h"
#import <WCDBObjc/WCDBObjc.h>

NS_ASSUME_NONNULL_BEGIN

@interface NLSearchRecord (WCDB) <WCTTableCoding>
WCDB_PROPERTY(keyword)
WCDB_PROPERTY(timestamp)
@end

NS_ASSUME_NONNULL_END
