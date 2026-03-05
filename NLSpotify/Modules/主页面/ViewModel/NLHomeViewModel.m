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

@implementation NLHomeViewModel

- (void)loadDataWithCompletion:(void (^)(void))completion {
    NSMutableArray *sectionsArray = [NSMutableArray arrayWithObjects:[NSNull null], [NSNull null], [NSNull null], [NSNull null], [NSNull null], nil];
    dispatch_group_t group = dispatch_group_create();

    // 1. 为你推荐（个性化）
    dispatch_group_enter(group);
    [[NLRecommendAlbumListService sharedService] fetchRecommendPlayListWithLimit:8 success:^(NSArray<NLRecommendAlbumListModel *> * _Nonnull list) {
        sectionsArray[0] = [NLSectionViewModel sectionWithStyle:NLHomeSectionStylePlaylist title:@"为你推荐" items:list];
        dispatch_group_leave(group);
    } failure:^(NSError * _Nonnull error) {
        dispatch_group_leave(group);
    }];

    // 2. 歌手专辑（林俊杰）
    dispatch_group_enter(group);
    [[NLSingerAlbumListService sharedService] fetchSingerListWithSuccess:^(NSArray<NLSingerAlbumListModel *> * _Nonnull singers) {
        sectionsArray[1] = [NLSectionViewModel sectionWithStyle:NLHomeSectionStyleSingerAlbum title:@"林俊杰" items:singers];
        dispatch_group_leave(group);
    } failure:^(NSError * _Nonnull error) {
        dispatch_group_leave(group);
    }];

    // 3. 华语精品
    dispatch_group_enter(group);
    [[NLChineseSongListService sharedService] fetchHighQualityPlaylistsWithCategory:@"华语" limit:8 success:^(NSArray<NLRecommendAlbumListModel *> * _Nonnull list) {
        sectionsArray[2] = [NLSectionViewModel sectionWithStyle:NLHomeSectionStylePlaylist title:@"华语精品" items:list];
        dispatch_group_leave(group);
    } failure:^(NSError * _Nonnull error) {
        dispatch_group_leave(group);
    }];

    // 4. 欧美
    dispatch_group_enter(group);
    [[NLChineseSongListService sharedService] fetchHighQualityPlaylistsWithCategory:@"欧美" limit:8 success:^(NSArray<NLRecommendAlbumListModel *> * _Nonnull list) {
        sectionsArray[3] = [NLSectionViewModel sectionWithStyle:NLHomeSectionStylePlaylist title:@"欧美" items:list];
        dispatch_group_leave(group);
    } failure:^(NSError * _Nonnull error) {
        dispatch_group_leave(group);
    }];

    // 5. 流行
    dispatch_group_enter(group);
    [[NLChineseSongListService sharedService] fetchHighQualityPlaylistsWithCategory:@"流行" limit:8 success:^(NSArray<NLRecommendAlbumListModel *> * _Nonnull list) {
        sectionsArray[4] = [NLSectionViewModel sectionWithStyle:NLHomeSectionStylePlaylist title:@"流行" items:list];
        dispatch_group_leave(group);
    } failure:^(NSError * _Nonnull error) {
        dispatch_group_leave(group);
    }];
//  当上面这几个group都完成（enter的次数和leave相等）以后执行这个blcok
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSMutableArray *valid = [NSMutableArray array];
        for (id obj in sectionsArray) {
            if (![obj isKindOfClass:[NSNull class]]) {
                // 如果这是空的，也就是没请求，那就不佳
                [valid addObject:obj];
            }
        }
        self.sections = [valid copy];
        if (completion) completion();
    });
//    [[NLRecommendAlbumListService sharedService] fetchRecommendPlayListWithLimit:8 success:^(NSArray<NLRecommendAlbumListModel *> * _Nonnull models) {
//
//        NLSectionViewModel *smallSection =
//        [NLSectionViewModel sectionWithStyle:NLHomeSectionStylePlaylist
//                                        title:@"为你推荐"
//                                        items:models];
//        [sectionsArray addObject:smallSection];
//
//        [[NLSingerAlbumListService sharedService] fetchSingerListWithSuccess:^(NSArray<NLSingerAlbumListModel *> * _Nonnull singers) {
//
//            NLSectionViewModel *bigSection =
//            [NLSectionViewModel sectionWithStyle:NLHomeSectionStyleSingerAlbum
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
