//
//  RCTitleButton.m
//  高仿微博
//
//  Created by Raychen on 15/4/7.
//  Copyright (c) 2015年 raychen. All rights reserved.
//

#import "RCTitleButton.h"
#import "UIView+Extension.h"
static const NSUInteger RCMargin = 5;
@implementation RCTitleButton


- (instancetype)initWithFrame:(CGRect)frame{
    if ([super initWithFrame:frame]) {
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        [self setImage:[UIImage imageNamed:@"findsection_more_n"] forState:UIControlStateNormal];
        self.imageView.contentMode = UIViewContentModeRight;
        self.titleLabel.contentMode = UIViewContentModeLeft;
        self.imageEdgeInsets = UIEdgeInsetsMake(0, 50, 0, 0);
        self.titleEdgeInsets = UIEdgeInsetsMake(0, -100, 0, 0);


    }

    return self;
    
    
}
- (void)setFrame:(CGRect)frame{
    frame.size.width += RCMargin;
    [super setFrame:frame];

}
- (void)layoutSubviews{
    [super layoutSubviews];
    self.titleLabel.x = self.imageView.x-150;
    self.imageView.x = CGRectGetMaxX(self.titleLabel.frame) + RCMargin+240;
}
- (void)setTitle:(NSString *)title forState:(UIControlState)state
{
    [super setTitle:title forState:state];
    
    // 只要修改了文字，就让按钮重新计算自己的尺寸
    [self sizeToFit];
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state
{
    [super setImage:image forState:state];
    
    // 只要修改了图片，就让按钮重新计算自己的尺寸
    [self sizeToFit];
}

@end
