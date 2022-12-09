//
//  CRGiftListView.m
//  ChatRoom
//
//  Created by Apple on 2020/7/24.
//

#import "CRGiftListView.h"
#import "YuerGiftCell.h"
#import "Masonry.h"
#import "CRRoomListModel.h"
#import "CRGiftModel.h"


@interface CRRewardGiftSelectorFlowLayout()
@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *arrayM;
@end


@implementation CRRewardGiftSelectorFlowLayout

- (void)prepareLayout {
    [super prepareLayout];
    self.pageCount = [self.collectionView numberOfItemsInSection:0] / (self.itemCountPerRow * self.rowCount);
    if ([self.collectionView numberOfItemsInSection:0] % (self.itemCountPerRow * self.rowCount) > 0) {
        self.pageCount++;
    }
    self.pContentSizeW = self.itemSize.width * self.itemCountPerRow + self.itemCountPerRow * self.minimumLineSpacing + self.sectionInset.left + self.sectionInset.right;
    self.pContentSizeH = self.itemSize.height * self.rowCount + (self.rowCount - 1) * self.minimumInteritemSpacing + self.sectionInset.top + self.sectionInset.bottom;
    
    self.arrayM = [NSMutableArray new];
    NSInteger items = [self.collectionView numberOfItemsInSection:0];
    for (int i = 0; i < items; i++) {
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        NSInteger itemIdx = i;
        CGFloat currentPage = itemIdx / (self.itemCountPerRow * self.rowCount);
        CGFloat itemX = itemIdx % self.itemCountPerRow * (self.itemSize.width + self.minimumLineSpacing) + currentPage * self.pContentSizeW + self.sectionInset.left;
        CGFloat itemY = itemIdx / self.itemCountPerRow % self.rowCount * (self.itemSize.height + self.minimumInteritemSpacing) + self.sectionInset.top;
        attributes.frame = CGRectMake(itemX, itemY, self.itemSize.width, self.itemSize.height);
        [self.arrayM addObject:attributes];
    }
}

- (CGSize)collectionViewContentSize {
    return CGSizeMake(self.pageCount * self.pContentSizeW, self.pContentSizeH);
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.arrayM.copy;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

@end


@interface CRGiftListView ()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, strong) NSIndexPath *lastSelectedIndex;

@end

@implementation CRGiftListView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self creatCollectionViewWith:frame];
    }
    return self;
}

- (void)creatCollectionViewWith:(CGRect)frame {
    CGFloat itemW = UIScreen.mainScreen.bounds.size.width / 4.0;
    
    CRRewardGiftSelectorFlowLayout *layout = [CRRewardGiftSelectorFlowLayout new];
    layout.itemCountPerRow = 4;
    layout.rowCount = 2;
    layout.itemSize = CGSizeMake(itemW, 100.f);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)
                                                          collectionViewLayout:layout];
        
        
    
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.pagingEnabled  = YES;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.bounces = NO;
    collectionView.alwaysBounceHorizontal = YES;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [collectionView registerClass:[YuerGiftCell class] forCellWithReuseIdentifier:NSStringFromClass(YuerGiftCell.class)];
    [self addSubview:collectionView];
    self.listView = collectionView;
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return self.listData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YuerGiftCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(YuerGiftCell.class)
                                                                   forIndexPath:indexPath];
    [cell bindModel:self.listData[indexPath.row]];
    return cell;
   
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CRGiftModel *current = self.listData[indexPath.row];
    if (current.selected) {
        return;
    }
    current.selected = true;
    NSMutableArray *indexPaths = @[].mutableCopy;
    
    [indexPaths addObject:[NSIndexPath indexPathForRow:indexPath.row
                                             inSection:indexPath.section]];
    
    if (self.lastSelectedIndex) {
        CRGiftModel *last = self.listData[self.lastSelectedIndex.row];
        last.selected = false;
        [indexPaths addObject:[NSIndexPath indexPathForRow:self.lastSelectedIndex.row
                                                 inSection:self.lastSelectedIndex.section]];

    }
    self.lastSelectedIndex = indexPath;
    [UIView performWithoutAnimation:^{
        [collectionView reloadItemsAtIndexPaths:indexPaths];
    }];
    
    !self.onSelectedGift ? : self.onSelectedGift(current);
}

#pragma mark - Setter

- (void)setListData:(NSArray<CRGiftModel *> *)listData {
    _listData = listData;
    self.lastSelectedIndex = nil;
    [self.listView reloadData];
}

@end
