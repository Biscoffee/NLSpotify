//
//  NLPLayListSongRelation+WCDB.h
//  NLSpotify
//
//  Created by 吴桐 on 2026/2/23.
//

#import "NLPlayListSongRelation.h"
#import <WCDBObjc/WCDBObjc.h>

NS_ASSUME_NONNULL_BEGIN
@interface NLPlayListSongRelation (WCDB) <WCTTableCoding>
WCDB_PROPERTY(playlistId)
WCDB_PROPERTY(songId)
WCDB_PROPERTY(addTime)
@end
NS_ASSUME_NONNULL_END
