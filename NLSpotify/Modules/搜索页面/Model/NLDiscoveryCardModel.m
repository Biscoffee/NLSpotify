//
//  NLDiscoveryCardModel.m
//  NLSpotify
//
//  Created by 吴桐 on 2026/1/16.
//

#import "NLDiscoveryCardModel.h"

@implementation NLDiscoveryCardModel

+ (NSArray<NLDiscoveryCardModel *> *)defaultDiscoveryCards {
    return @[
        [self cardWithTitle:@"#华语流行音乐"
                 imageName:@"discovery_chinese_pop"
         backgroundColorHex:@"#FF6B6B"],

        [self cardWithTitle:@"#xinyao"
                 imageName:@"discovery_xinyao"
         backgroundColorHex:@"#4ECDC4"],

        [self cardWithTitle:@"为你推荐"
                 imageName:@"discovery_recommend"
         backgroundColorHex:@"#45B7D1"]
    ];
}

+ (instancetype)cardWithTitle:(NSString *)title
                    imageName:(NSString *)imageName
           backgroundColorHex:(NSString *)hexColor {
    NLDiscoveryCardModel *model = [[self alloc] init];
    model.title = title;
    model.imageName = imageName;
    model.backgroundColorHex = hexColor;
    return model;
}

@end
