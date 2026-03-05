//
//  NLLyricLine.h
//  NLSpotify
//
//  Created by 吴桐 on 2026/3/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NLLyricLine : NSObject

/// 该行歌词的开始时间（秒）
@property (nonatomic, assign) NSTimeInterval time;
/// 该行歌词的文本内容
@property (nonatomic, copy) NSString *text;

@end

NS_ASSUME_NONNULL_END

