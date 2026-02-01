//
//  NLDrawerModels.h
//  NLSpotify
//
//  抽屉视图数据模型（MVC - Model）
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Profile

@interface NLDrawerProfileModel : NSObject
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *profileLinkText;
@property (nonatomic, copy) NSString *statusButtonTitle;
@property (nonatomic, strong, nullable) UIImage *avatarImage;
+ (instancetype)defaultModel;
@end

#pragma mark - Menu Item

@interface NLDrawerMenuItem : NSObject
@property (nonatomic, copy) NSString *iconName;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) BOOL highlightNew;
+ (instancetype)itemWithIcon:(NSString *)iconName title:(NSString *)title highlightNew:(BOOL)highlightNew;
+ (NSArray<NLDrawerMenuItem *> *)defaultMenuItems;
@end

#pragma mark - Message Section

@interface NLDrawerMessageSectionModel : NSObject
@property (nonatomic, copy) NSString *sectionTitle;
@property (nonatomic, copy) NSString *sectionDescription;
@property (nonatomic, copy) NSString *messageItemTitle;   
@property (nonatomic, copy) NSString *messageItemIconName; // 新消息行图标名
+ (instancetype)defaultModel;
@end

NS_ASSUME_NONNULL_END
