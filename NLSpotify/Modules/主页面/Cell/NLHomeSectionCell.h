//
//  NLHomeSectionCell.h
//  NLSpotify
//
//  Created by 吴桐 on 2025/12/13.
//

#import <UIKit/UIKit.h>
#import "NLSectionViewModel.h"

@class NLSectionViewModel;

NS_ASSUME_NONNULL_BEGIN

@interface NLHomeSectionCell : UITableViewCell<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NLSectionViewModel *sectionVM;
@property (nonatomic, assign) BOOL collapsed;

@property (nonatomic, assign) NSInteger sectionIndex;
- (void)configWithSectionVM:(NLSectionViewModel *)sectionVM;

- (void)registerCollectionCells;
- (CGSize)sizeForCollectionCell;
- (UICollectionViewCell *)configureCollectionCell:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath item:(id)item;

@end

NS_ASSUME_NONNULL_END
