//
//  RCHotAudioViewCell.h
//  喜马拉雅
//
//  Created by Raychen on 15/5/21.
//  Copyright (c) 2015年 raychen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCOnneHotAudio.h"
@interface RCHotAudioViewCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property(nonatomic,strong) RCOnneHotAudio  *audio;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;

@end
