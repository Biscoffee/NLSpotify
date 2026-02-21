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

/// 共有 UI：标题、点击区、箭头、横向列表容器
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NLSectionViewModel *sectionVM;

// 是否折叠（只显示标题区，隐藏列表）
@property (nonatomic, assign) BOOL collapsed;
// 当前 cell 所在的 section 索引（用于通知 controller 切换折叠状态）
@property (nonatomic, assign) NSInteger sectionIndex;
/// 点击标题区时回调，参数为当前 section 的 index
@property (nonatomic, copy, nullable) void (^didTapHeader)(NSInteger sectionIndex);

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
