//
//  NLDiscoveryCardModel.h
//  NLSpotify
//
//  Created by 吴桐 on 2026/1/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NLDiscoveryCardModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) NSString *backgroundColorHex; // 十六进制颜色

+ (NSArray<NLDiscoveryCardModel *> *)defaultDiscoveryCards;

@end

NS_ASSUME_NONNULL_END
