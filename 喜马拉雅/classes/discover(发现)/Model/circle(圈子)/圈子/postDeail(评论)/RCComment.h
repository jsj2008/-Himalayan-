//
//  RCComment.h
//  喜马拉雅
//
//  Created by Raychen on 15/5/23.
//  Copyright (c) 2015年 raychen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCComment : NSObject
/**
 *   "comments": [],
 "parentComments": []
 */
@property(nonatomic,strong) NSArray  *comments;
@property(nonatomic,strong) NSArray  *parentComments;
@end
