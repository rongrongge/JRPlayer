//
//  ViewController.m
//  JRPlayer
//
//  Created by 谢建荣 on 16/10/21.
//  Copyright © 2016年 Ping An Health Insurance Company of China. All rights reserved.
//

#import "ViewController.h"
#import "JRPlayView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    JRPlayView *playView = [[JRPlayView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENW / 16 * 9) videoUrl:@"minion_02.mp4" isAutoReplay:YES];
    [self.view addSubview:playView];
    
}

@end
