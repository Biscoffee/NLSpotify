//
//  NLSong+WCDB.h
//  NLSpotify
//
//  Created by 吴桐 on 2026/2/23.
//

#import "NLSong.h"
#import <WCDBObjc/WCDBObjc.h>

NS_ASSUME_NONNULL_BEGIN

@interface NLSong (WCDB) <WCTTableCoding>

WCDB_PROPERTY(songId)
WCDB_PROPERTY(title)
WCDB_PROPERTY(artist)
WCDB_PROPERTY(coverURL)
WCDB_PROPERTY(playURL)

@end

NS_ASSUME_NONNULL_END
