//
//  NLAlbum+WCDB.h
//  NLSpotify
//

#import "NLAlbum.h"
#import <WCDBObjc/WCDBObjc.h>

NS_ASSUME_NONNULL_BEGIN

@interface NLAlbum (WCDB) <WCTTableCoding>
WCDB_PROPERTY(albumId)
WCDB_PROPERTY(name)
WCDB_PROPERTY(coverURL)
WCDB_PROPERTY(artistName)
WCDB_PROPERTY(createTime)
@end

NS_ASSUME_NONNULL_END
