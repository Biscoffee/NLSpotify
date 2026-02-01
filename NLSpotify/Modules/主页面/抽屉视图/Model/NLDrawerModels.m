//
//  NLDrawerModels.m
//  NLSpotify
//

#import "NLDrawerModels.h"

@implementation NLDrawerProfileModel
+ (instancetype)defaultModel {
    NLDrawerProfileModel *m = [[NLDrawerProfileModel alloc] init];
    m.userName = @"Northern Lights.";
    m.profileLinkText = @"查看个人资料";
    m.statusButtonTitle = @"动态已关闭";
    m.avatarImage = nil;
    return m;
}
@end

@implementation NLDrawerMenuItem
+ (instancetype)itemWithIcon:(NSString *)iconName title:(NSString *)title highlightNew:(BOOL)highlightNew {
    NLDrawerMenuItem *item = [[NLDrawerMenuItem alloc] init];
    item.iconName = iconName;
    item.title = title;
    item.highlightNew = highlightNew;
    return item;
}
+ (NSArray<NLDrawerMenuItem *> *)defaultMenuItems {
    return @[
        [self itemWithIcon:@"person.badge.plus" title:@"添加帐号" highlightNew:NO],
        [self itemWithIcon:@"bolt.fill" title:@"新增内容" highlightNew:NO],
        [self itemWithIcon:@"chart.line.uptrend.xyaxis" title:@"收听统计信息・新增" highlightNew:YES],
        [self itemWithIcon:@"clock.arrow.circlepath" title:@"最近播放" highlightNew:NO],
        [self itemWithIcon:@"gearshape.fill" title:@"设置和隐私" highlightNew:NO]
    ];
}
@end

@implementation NLDrawerMessageSectionModel
+ (instancetype)defaultModel {
    NLDrawerMessageSectionModel *m = [[NLDrawerMessageSectionModel alloc] init];
    m.sectionTitle = @"消息";
    m.sectionDescription = @"直接在 Spotify 上与好友分享你的心头好。";
    m.messageItemTitle = @"新消息";
    m.messageItemIconName = @"square.and.pencil";
    return m;
}
@end
