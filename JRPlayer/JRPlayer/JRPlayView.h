//
//  JRPlayView.h
//  JRPlayer
//
//  Created by 谢建荣 on 16/10/24.
//  Copyright © 2016年 Ping An Health Insurance Company of China. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+FrameLayout.h"
#import "UILabel+Size.h"

#define SCREENW [UIScreen mainScreen].bounds.size.width
#define SCREENH [UIScreen mainScreen].bounds.size.height

#define BtnWH 30 //播放切换和全屏切换按钮的宽和高

@interface JRPlayView : UIView

/**
 * 初始化视频播放器
 *
 * @param frame     播放器大小
 * @param videoUrl  视频地址
 * @param isAutoReplay  设置自动重复播放  YES:自动重复播放 NO:不重复播放
 *
 * @return 视频播放器对象
 */
- (instancetype)initWithFrame:(CGRect)frame videoUrl:(NSString *)videoUrl isAutoReplay:(BOOL)isAutoReplay;

@end
