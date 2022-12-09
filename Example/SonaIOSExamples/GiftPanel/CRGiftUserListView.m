//
//  CRGiftUserListView.m
//  SonaIOSExamples
//
//  Created by Ju Liaoyuan on 2022/11/15.
//

#import "CRGiftUserListView.h"
#import "Masonry.h"
#import "UIColor+HEX.h"
#import "YuerGiftUserCell.h"
#import "CRRoomInfoResult.h"

@interface CRGiftUserListView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, copy) NSArray<CRRoomInfoSeatModel *> *seatList;

@property (nonatomic, copy) NSString *selectedUid;

@property (nonatomic, strong) NSIndexPath *lastSelectedIndexPath;

@end

@implementation CRGiftUserListView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    UIView *bgView = self;
    bgView.backgroundColor = [UIColor clearColor];
    self.cornerBgView = [UIView new];
    self.cornerBgView.backgroundColor = [UIColor clearColor];
    self.cornerBgView.layer.cornerRadius = 12.0f;
    self.cornerBgView.layer.masksToBounds = YES;
    [bgView addSubview:self.cornerBgView];
    
    [self.cornerBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(8);
        make.width.mas_equalTo(bgView.frame.size.width - 16);
        make.height.mas_equalTo(58);
        make.top.mas_equalTo(0);
    }];
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.itemSize = CGSizeMake(48, 54);
    layout.minimumLineSpacing = .0f;
    layout.minimumInteritemSpacing = 0.0f;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.rewardUsersList = [[UICollectionView alloc] initWithFrame:CGRectMake(50.f, 0, bgView.frame.size.width - 50 - 68, 58) collectionViewLayout:layout];
    [self.rewardUsersList registerClass:[YuerGiftUserCell class] forCellWithReuseIdentifier:NSStringFromClass([YuerGiftUserCell class])];
    self.rewardUsersList.backgroundColor = [UIColor clearColor];
    self.rewardUsersList.showsHorizontalScrollIndicator = NO;
    self.rewardUsersList.allowsSelection = YES;
    self.rewardUsersList.delegate = self;
    self.rewardUsersList.dataSource = self;
    [self.cornerBgView addSubview:self.rewardUsersList];
    [self.cornerBgView addSubview:self.sendLabel];
    [self.sendLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(34.0f);
        make.height.mas_equalTo(17.0f);
        make.left.mas_equalTo(self.cornerBgView).offset(10.0f);
        make.centerY.mas_equalTo(self.cornerBgView.mas_centerY);
    }];
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.seatList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YuerGiftUserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([YuerGiftUserCell class])
                                                                       forIndexPath:indexPath];
    CRRoomInfoSeatModel *model = self.seatList[indexPath.row];
    model.index = indexPath.row;
    [cell bindModel:model];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CRRoomInfoSeatModel *seat = self.seatList[indexPath.row];
    if ([self.selectedUid isEqualToString:seat.uid]) {
        return;
    }
    
    NSMutableArray *indexPaths = @[].mutableCopy;
    
    seat.selected = true;
    self.selectedUid = seat.uid;

    [indexPaths addObject:indexPath];
    
    if (self.lastSelectedIndexPath) {
        CRRoomInfoSeatModel *seat = self.seatList[self.lastSelectedIndexPath.row];
        seat.selected = false;
        [indexPaths addObject:self.lastSelectedIndexPath];
    }
    
    self.lastSelectedIndexPath = indexPath;
    
    [UIView performWithoutAnimation:^{
        [collectionView reloadItemsAtIndexPaths:indexPaths];
    }];
    
    !self.onSelectedSeat ? : self.onSelectedSeat(self.selectedUid);
}


- (void)updateModel:(NSArray<CRRoomInfoSeatModel *> *)seatList {
    self.seatList = seatList;
    self.lastSelectedIndexPath = nil;
    [self.rewardUsersList reloadData];
}

- (UILabel *)sendLabel {
    if (!_sendLabel) {
        _sendLabel = [UILabel new];
        _sendLabel.text = @"送给";
        _sendLabel.font = [UIFont systemFontOfSize:12];
        _sendLabel.textColor = UIColor.whiteColor;
        _sendLabel.backgroundColor = [UIColor clearColor];
        _sendLabel.numberOfLines = 1;
    }
    return _sendLabel;
}

@end
