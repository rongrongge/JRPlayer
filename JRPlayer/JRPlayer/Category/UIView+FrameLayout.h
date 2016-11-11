//
//  UIView+FrameLayout.h
//  JRChatDemo
//
//  Created by 谢建荣 on 16/10/20.
//  Copyright © 2016年 Ping An Health Insurance Company of China. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (FrameLayout)

@property (nonatomic) CGFloat left;
@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat right;
@property (nonatomic) CGFloat bottom;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;

@property (nonatomic) CGFloat centerX;
@property (nonatomic) CGFloat centerY;

@property (nonatomic) CGPoint origin;
@property (nonatomic) CGSize size;

@end
