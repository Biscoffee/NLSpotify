//
//  NLHomeViewModel.m
//  NLSpotify
//
//  Created by 吴桐 on 2025/12/13.
//

#import "NLHomeViewModel.h"
#import "NLSingerAlbumListModel.h"
#import "NLRecommendAlbumListModel.h"
#import "NLSectionViewModel.h"
#import "NLRecommendAlbumListService.h"
#import "NLSingerAlbumListService.h"
#import "NLChineseSongListService.h"
#import "NLSingerAlbumListModel.h"

@implementation NLHomeViewModel

- (void)loadDataWithCompletion:(void (^)(void))completion {
    NSMutableArray *sectionsArray = [NSMutableArray array];
  dispatch_group_t group = dispatch_group_create();
  dispatch_group_enter(group);
  [[NLRecommendAlbumListService sharedService] fetchRecommendPlayListWithLimit:8 success:^(NSArray<NLRecommendAlbumListModel *> * _Nonnull list) {
    NLSectionViewModel *smallModel = [NLSectionViewModel sectionWithStyle:NLHomeSectionStylePlayListSmall title:@"为你推荐" items:list];
    [sectionsArray addObject:smallModel];
    dispatch_group_leave(group);
  } failure:^(NSError * _Nonnull error) {
    dispatch_group_leave(group);
  }];
  dispatch_group_enter(group);
  [[NLSingerAlbumListService sharedService] fetchSingerListWithSuccess:^(NSArray<NLSingerAlbumListModel *> * _Nonnull singers) {
    NLSectionViewModel *big = [NLSectionViewModel sectionWithStyle:NLHomeSectionStylePlayListBig title:@"ljj" items:singers];
    [sectionsArray addObject:big];
    dispatch_group_leave(group);
  } failure:^(NSError * _Nonnull error) {
    dispatch_group_leave(group);
  }];
  dispatch_group_enter(group);
  [[NLChineseSongListService sharedService] fetchRecommendPlayListWithLimit:8 success:^(NSArray<NLRecommendAlbumListModel *> * _Nonnull list) {
    NLSectionViewModel *smallModel = [NLSectionViewModel sectionWithStyle:NLHomeSectionStylePlayListSmall title:@"为你推荐" items:list];
    [sectionsArray addObject:smallModel];
    dispatch_group_leave(group);
  } failure:^(NSError * _Nonnull error) {
    dispatch_group_leave(group);
  }];
  dispatch_group_notify(group, dispatch_get_main_queue(), ^{
    self.sections = [sectionsArray copy];
    if (completion) completion();
  });
//    [[NLRecommendAlbumListService sharedService] fetchRecommendPlayListWithLimit:8 success:^(NSArray<NLRecommendAlbumListModel *> * _Nonnull models) {
//
//        NLSectionViewModel *smallSection =
//        [NLSectionViewModel sectionWithStyle:NLHomeSectionStylePlayListSmall
//                                        title:@"为你推荐"
//                                        items:models];
//        [sectionsArray addObject:smallSection];
//
//        [[NLSingerAlbumListService sharedService] fetchSingerListWithSuccess:^(NSArray<NLSingerAlbumListModel *> * _Nonnull singers) {
//
//            NLSectionViewModel *bigSection =
//            [NLSectionViewModel sectionWithStyle:NLHomeSectionStylePlayListBig
//                                            title:@"林俊杰"
//                                            items:singers];
//            [sectionsArray addObject:bigSection];
//            self.sections = [sectionsArray copy];
//
//            if (completion) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    completion();
//                });
//            }
//
//        } failure:^(NSError * _Nonnull error) {
//            self.sections = [sectionsArray copy];
//            if (completion) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    completion();
//                });
//            }
//        }];
//
//    } failure:^(NSError * _Nonnull error) {
//        NSLog(@"推荐歌单加载失败");
//    }];
}

- (NSInteger)numberOfSections {
    return self.sections.count;
}

- (NLSectionViewModel *)sectionAtIndex:(NSInteger)index {
    return self.sections[index];
}
@end
