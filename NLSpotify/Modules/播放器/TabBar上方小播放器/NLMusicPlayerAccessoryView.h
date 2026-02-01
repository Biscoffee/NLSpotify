//
//  NLMusicPlayerAccessoryView.h
//  NLSpotify
//
//  Created by 吴桐 on 2025/12/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NLMusicPlayerAccessoryView;

@protocol NLMusicPlayerAccessoryViewDelegate <NSObject>
- (void)accessoryViewDidTap:(NLMusicPlayerAccessoryView *)view;
@end

@interface NLMusicPlayerAccessoryView : UIView

@property (nonatomic, weak) id<NLMusicPlayerAccessoryViewDelegate> delegate;

- (void)bindPlayer;

@end

NS_ASSUME_NONNULL_END
