//
//  NLDownloadItem.mm
//  NLSpotify
//

#import "NLDownloadItem.h"
#import <WCDBObjc/WCDBObjc.h>

@implementation NLDownloadItem

WCDB_IMPLEMENTATION(NLDownloadItem)
WCDB_SYNTHESIZE(songId)
WCDB_SYNTHESIZE(playURLString)
WCDB_SYNTHESIZE(title)
WCDB_SYNTHESIZE(artist)
WCDB_SYNTHESIZE(coverURLString)
WCDB_SYNTHESIZE(addedTime)
WCDB_SYNTHESIZE(status)
WCDB_PRIMARY(songId)

- (NSURL *)playURL {
    if (self.playURLString.length == 0) return nil;
    return [NSURL URLWithString:self.playURLString];
}

@end
