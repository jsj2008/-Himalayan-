//
//  RCAlbumDeailViewController.m
//
//
//  Created by Raychen on 15/5/25.
//  Copyright (c) 2015年 raychen. All rights reserved.
//

#import "RCAlbumDeailViewController.h"
#import "CSCell.h"
#import "CSStickyHeaderFlowLayout.h"
#import "RCAlbumViewModel.h"
#import "RCSegementControl.h"
#import "RCAlbumSectionHeaderView.h"
#import "MJRefresh.h"
#import "Toast+UIView.h"
#import "RCHotAudioViewCell.h"
#import "RCDiscoverViewController.h"
#import "RCAlbumViewController.h"
#import "RCConst.h"
#import "RCAlbumDeailViewCell.h"
#import "RCAlbumHeaderView.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
@interface RCAlbumDeailViewController () <RCSegementControlDelegate>
@property (nonatomic, strong) NSArray *sections;
@property(nonatomic,strong) RCAlbumViewModel  *viewModel;
@end

@implementation RCAlbumDeailViewController
-  (RCAlbumViewModel *)viewModel{
    if (!_viewModel) {
        self.viewModel = [[RCAlbumViewModel alloc]init];
        self.viewModel.ID = self.ID;
    }
    return _viewModel;
}
- (instancetype)init
{
    CSStickyHeaderFlowLayout *layout = [[CSStickyHeaderFlowLayout alloc]init];

    if ([layout isKindOfClass:[CSStickyHeaderFlowLayout class]]) {
        [layout setHeaderReferenceSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, 30)];
        layout.parallaxHeaderReferenceSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 240);
        layout.parallaxHeaderMinimumReferenceSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 112);
        layout.parallaxHeaderAlwaysOnTop = YES;
        layout.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 105);
        // If we want to disable the sticky header effect
        layout.disableStickyHeaders = YES;
    }

    return [super initWithCollectionViewLayout:layout];
}
- (void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [super viewWillDisappear:animated];

}
- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [super viewWillAppear:animated];

}


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"%@",self.navigationController.viewControllers);

    [self.viewModel fetchNewAlbumDeailDataWithSuccess:^{
        [self.collectionView reloadData];
    } failure:^{

    }];

    [self setRefresh];
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        CGRect rect = self.collectionView.frame;
        rect.origin.y -= 20;
        self.collectionView.frame = rect;
    }
    [self.collectionView registerNib:[UINib nibWithNibName:@"RCAlbumHeaderView" bundle:nil]
          forSupplementaryViewOfKind:CSStickyHeaderParallaxHeader
                 withReuseIdentifier:@"header"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"CSCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerNib:[UINib nibWithNibName:@"RCAlbumDeailViewCell" bundle:nil] forCellWithReuseIdentifier:@"AlbumDeailCell"];

    [self.collectionView registerNib:[UINib nibWithNibName:@"RCAlbumSectionHeaderView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"sectionheaderView"];

}
- (void)setRefresh{
    // 设置普通状态的动画图片
    NSMutableArray *idleImages = [NSMutableArray array];
    for (NSUInteger i = 1; i<=60; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"dropdown_anim__000%zd", i]];
        [idleImages addObject:image];
    }

    // 设置即将刷新状态的动画图片（一松开就会刷新的状态）
    NSMutableArray *refreshingImages = [NSMutableArray array];
    for (NSUInteger i = 1; i<=3; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"dropdown_loading_0%zd", i]];
        [refreshingImages addObject:image];
    }
    // 添加动画图片的上拉刷新
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
    [self.collectionView addGifFooterWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];

    // 设置正在刷新状态的动画图片
    for (NSUInteger i = 1; i<=3; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"dropdown_loading_0%zd", i]];
        [refreshingImages addObject:image];
    }
    self.collectionView.gifFooter.refreshingImages = refreshingImages;

}
- (void)loadMoreData{

    [self.viewModel fetchMoreAlbumDeailDataWithSuccess:^{
        [self.collectionView reloadData];
        [self.collectionView.gifFooter  endRefreshing];
    } failure:^{
        [self.collectionView.gifFooter  endRefreshing];

    } completion:^{
        [self.collectionView.gifFooter  endRefreshing];
        [[UIApplication sharedApplication].keyWindow makeToast:@"没有更多的数据了" duration:2 position:@"bottom"];
        self.collectionView.gifFooter.hidden = YES;
    }];
}
#pragma mark UICollectionViewDataSource


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.viewModel numberOfRowOfAlbumDeailDataInSection:section];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    RCAlbumDeailViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AlbumDeailCell" forIndexPath:indexPath];
    RCTrackList * trackList = [self.viewModel trackListAtIndexPath:indexPath];
    cell.trackList = trackList;
    @weakify(self);
    [[cell.downloadButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton * button) {
        @strongify(self);
        trackList.downloaded = YES;
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        [[UIApplication sharedApplication].keyWindow makeToast:@"加入下载队列成功" duration:1 position:@"bottom"];
    }];
    return cell;
}




- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind  isEqualToString:UICollectionElementKindSectionHeader]) {
        RCAlbumSectionHeaderView * sectionheaderView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"sectionheaderView" forIndexPath:indexPath];
        sectionheaderView.albumCountlabel.text = [NSString stringWithFormat:@"声音(%@)",self.viewModel.totalCount];
        [[sectionheaderView.sortButton rac_signalForControlEvents:UIControlEventTouchDown] subscribeNext:^(UIButton * sortButton) {
            sortButton.selected = !sortButton.isSelected;
            if (sortButton.isSelected) {
            [self.viewModel.trarkLists sortUsingComparator:^NSComparisonResult(RCTrackList * obj1, RCTrackList * obj2) {
                if (obj1.createdAt > obj2.createdAt) {
                    return NSOrderedDescending;
                }
                return NSOrderedAscending;
            }];

            }else{
                [self.viewModel.trarkLists sortUsingComparator:^NSComparisonResult(RCTrackList * obj1, RCTrackList * obj2) {
                    if (obj1.createdAt > obj2.createdAt) {
                        return NSOrderedAscending;
                    }
                    return NSOrderedDescending;
                }];
            }
            [self.collectionView reloadData];

        }];
        return sectionheaderView;
    }else if ([kind isEqualToString:CSStickyHeaderParallaxHeader]) {
        RCAlbumHeaderView *headerView = [collectionView

        dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"header"forIndexPath:indexPath];
     headerView.album = self.viewModel.album;
        headerView.tracklist = self.viewModel.trarkLists;
        [headerView.back addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        [[headerView.saveButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton * button) {
            button.selected = YES;
        }];      
        return headerView;
    }
    return nil;
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];

}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
