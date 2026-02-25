//
//  NLSearchRecord.h
//  NLSpotify
//
//  Created by 吴桐 on 2026/2/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NLSearchRecord : NSObject

@property (nonatomic, copy) NSString *keyword;
@property (nonatomic, assign) NSTimeInterval timestamp; 

- (instancetype)initWithKeyword:(NSString *)keyword;

@end

NS_ASSUME_NONNULL_END
