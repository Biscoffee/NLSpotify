//
//  NLCategoryModel.m
//  NLSpotify
//
//  Created by 吴桐 on 2026/1/16.
//

#import "NLCategoryModel.h"

@implementation NLCategoryModel

+ (NSArray<NLCategoryModel *> *)defaultCategories {
    return @[
        [self categoryWithName:@"华语"
                     imageName:@"music_note"
            backgroundColorHex:@"#B3A2C7"  // 淡紫色偏灰
                    identifier:@"music"],

//        [self categoryWithName:@"古风"
//                     imageName:@"mic"
//            backgroundColorHex:@"#A2D5C6"  // 浅青绿色
//                    identifier:@"podcast"],

        [self categoryWithName:@"摇滚"
                     imageName:@"calendar"
            backgroundColorHex:@"#F2C6A0"  // 暖橙色
                    identifier:@"live"],

        [self categoryWithName:@"怀旧"
                     imageName:@"trophy"
            backgroundColorHex:@"#C4B7A6"  // 米灰色
                    identifier:@"year2025"],

        [self categoryWithName:@"欧美"
                     imageName:@"podcast_2025"
            backgroundColorHex:@"#D6E0F0"  // 冷灰蓝
                    identifier:@"podcast2025"],

        [self categoryWithName:@"清新"
                     imageName:@"person"
            backgroundColorHex:@"#E3F2D8"  // 浅绿黄
                    identifier:@"foryou"],

        [self categoryWithName:@"夜晚"
                     imageName:@"clock"
            backgroundColorHex:@"#A8C0D1"  // 柔和蓝灰
                    identifier:@"upcoming"],

        [self categoryWithName:@"儿童"
                     imageName:@"flame"
            backgroundColorHex:@"#F9E3D3"  // 浅橘粉
                    identifier:@"newhits"],

        [self categoryWithName:@"民谣"
                     imageName:@"chart.bar"
            backgroundColorHex:@"#C9D8B6"  // 柔和黄绿
                    identifier:@"pop"],

        [self categoryWithName:@"日语"
                     imageName:@"kpop"
            backgroundColorHex:@"#E6D1E8"  // 浅紫粉
                    identifier:@"kpop"],

        [self categoryWithName:@"舞曲"
                     imageName:@"hiphop"
            backgroundColorHex:@"#D1E2F0"  // 淡蓝色
                    identifier:@"hiphop"],

        [self categoryWithName:@"浪漫"
                     imageName:@"cpop"
            backgroundColorHex:@"#F5D3D1"  // 柔和粉橙
                    identifier:@"cpop"],

        [self categoryWithName:@"粤语"
                     imageName:@"chart.line"
            backgroundColorHex:@"#D1C8E0"  // 灰紫
                    identifier:@"charts"],

        [self categoryWithName:@"游戏"
                     imageName:@"star"
            backgroundColorHex:@"#C6E0DC"  // 浅青蓝
                    identifier:@"top_songs_1"],

        [self categoryWithName:@"下午茶"
                     imageName:@"star.fill"
            backgroundColorHex:@"#FBE8C2"  // 柔和奶油黄
                    identifier:@"top_songs_2"],

        [self categoryWithName:@"孤独"
                     imageName:@"globe"
            backgroundColorHex:@"#CFC4B2"  // 灰棕
                    identifier:@"global"],

        [self categoryWithName:@"轻音乐"
                     imageName:@"mandolin"
            backgroundColorHex:@"#D9E8F0"  // 浅天蓝
                    identifier:@"mandol_hits_1"],

        [self categoryWithName:@"爵士"
                     imageName:@"mandolin.fill"
            backgroundColorHex:@"#E3DDE3"  // 灰粉紫
                    identifier:@"mandol_hits_2"],

        [self categoryWithName:@"旅行"
                     imageName:@"chart.pie"
            backgroundColorHex:@"#BFD8E3"  // 淡蓝绿色
                    identifier:@"podcast_charts"]
    ];
}

+ (instancetype)categoryWithName:(NSString *)name
                       imageName:(NSString *)imageName
              backgroundColorHex:(NSString *)hexColor
                      identifier:(NSString *)identifier {
    NLCategoryModel *model = [[self alloc] init];
    model.name = name;
    model.imageName = imageName;
    model.backgroundColorHex = hexColor;
    model.identifier = identifier;
    return model;
}

@end
