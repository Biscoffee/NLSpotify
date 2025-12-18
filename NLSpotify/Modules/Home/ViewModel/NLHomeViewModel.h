//
//  NLHomeViewModel.h
//  NLSpotify
//
//  Created by 吴桐 on 2025/12/13.
//

#import <Foundation/Foundation.h>
#import "NLSectionViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NLHomeViewModel : NSObject

@property (nonatomic, strong) NSArray *sections;//储存所有分区的section

- (void)loadDataWithCompletion:(void (^)(void))completion;

- (NSInteger)numberOfSections;
- (NLSectionViewModel *)sectionAtIndex:(NSInteger *)index;

@end



NS_ASSUME_NONNULL_END
