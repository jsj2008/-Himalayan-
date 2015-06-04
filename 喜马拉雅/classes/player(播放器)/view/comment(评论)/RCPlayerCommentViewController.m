//
//  RCPlayerCommentViewController.m
//  喜马拉雅
//
//  Created by Raychen on 15/5/30.
//  Copyright (c) 2015年 raychen. All rights reserved.
//

#import "RCPlayerCommentViewController.h"
#import "RCConst.h"
#import "RCPlayerVIewModel.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "RCPlayerCommentViewCell.h"
static NSString * const ID = @"playerCommentCell";
@interface RCPlayerCommentViewController ()
@property(nonatomic,strong) RCPlayerVIewModel  *viewmodel;
@end
@implementation RCPlayerCommentViewController
-  (RCPlayerVIewModel *)viewmodel{
    if (!_viewmodel) {
        self.viewmodel = [[RCPlayerVIewModel alloc]init];
    }
    return _viewmodel;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.gifFooter.hidden = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.tableView registerNib:[UINib nibWithNibName:@"RCPlayerCommentViewCell" bundle:nil] forCellReuseIdentifier:ID];
    [self.tableView removeHeader];
    [RCNotificationCenter addObserver:self selector:@selector(fecthData:) name:sendNetWorkingNotification object:nil];

}
- (void)fecthData:(NSNotification *)note{
    self.viewmodel.trackId = note.userInfo[netWorkingParamNotification];
    [self.viewmodel fetchNewPlayerCommnetWithSuccess:^{
        [self.tableView reloadData];
    } failure:^{
    }];
}
- (void)loadMoreData{
    [self.viewmodel fetchMorePlayerCommnetWithSuccess:^{
        [self.tableView reloadData];
        [self.tableView.gifFooter endRefreshing];
    } failure:^{
        [self.tableView.gifFooter endRefreshing];

    } completion:^{
        [self.tableView.gifFooter endRefreshing];
        [self.tableView.gifFooter setHidden:YES];

    }];

}
#pragma mark - UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RCPlayerCommentViewCell * cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    RCPlayerCommnetList * commentList = self.viewmodel.comments[indexPath.row];
    commentList.follor = @(indexPath.row+1);
    cell.list = commentList;
    return cell;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return self.viewmodel.comments.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return [tableView fd_heightForCellWithIdentifier:ID cacheByIndexPath:indexPath configuration:^(RCPlayerCommentViewCell * cell) {
        cell.list = self.viewmodel.comments[indexPath.row];

    }];
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];


}
- (void)dealloc{

    [RCNotificationCenter removeObserver:self];
}
-(NSString *)segmentTitle{

return @"评论";
}


-(UIScrollView *)streachScrollView{

    return self.tableView;
}

@end
