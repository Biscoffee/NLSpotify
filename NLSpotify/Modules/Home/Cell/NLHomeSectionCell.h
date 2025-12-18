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

// smallCell
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NLSectionViewModel *sectionVM;

//bigCell
@property (nonatomic, strong) UIImageView *userAvatar;
@property (nonatomic, strong) UILabel *labelSmall;  //你的关注特供
@property (nonatomic, strong) UILabel *userName;


-(void)configWithSectionVM:(NLSectionViewModel *) sectionVM;

#pragma mark - 抽象方法：子类必须实现
/// 注册CollectionView的Cell（子类实现，只注册自己需要的Cell）
- (void)registerCollectionCells;
/// 返回CollectionViewCell的尺寸（子类实现，对应自己的样式）
- (CGSize)sizeForCollectionCell;
/// 渲染CollectionViewCell（子类实现，对应自己的Model）
- (UICollectionViewCell *)configureCollectionCell:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath item:(id)item;

@end

NS_ASSUME_NONNULL_END
