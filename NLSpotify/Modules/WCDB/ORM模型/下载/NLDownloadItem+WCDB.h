//
//  NLDownloadItem+WCDB.h
//  NLSpotify
//

#import "NLDownloadItem.h"
#import <WCDBObjc/WCDBObjc.h>

NS_ASSUME_NONNULL_BEGIN

@interface NLDownloadItem (WCDB) <WCTTableCoding>

WCDB_PROPERTY(songId)
WCDB_PROPERTY(playURLString)
WCDB_PROPERTY(title)
WCDB_PROPERTY(artist)
WCDB_PROPERTY(coverURLString)
WCDB_PROPERTY(addedTime)
WCDB_PROPERTY(status)

@end

NS_ASSUME_NONNULL_END
