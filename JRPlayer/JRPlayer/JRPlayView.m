//
//  JRPlayView.m
//  JRPlayer
//
//  Created by 谢建荣 on 16/10/24.
//  Copyright © 2016年 Ping An Health Insurance Company of China. All rights reserved.
//

#import "JRPlayView.h"
#import <AVFoundation/AVFoundation.h>

@interface JRPlayView ()

//全屏切换 YES:全屏 NO:非全屏
@property (nonatomic, assign) BOOL isChangeToFullScreen;
//播放切换 YES:播放 NO:暂停
@property (nonatomic, assign) BOOL isChangeToPlay;

@property (nonatomic, assign) BOOL isHideBottomView;
//自动重复播放 YES:自动重复 NO:不自动重复
@property (nonatomic, assign) BOOL isAutoReplay;

@property (nonatomic, strong) NSTimer *timer;

//记录frame
@property (nonatomic, assign) CGRect playFrame;
@property (nonatomic, assign) CGRect playBounds;

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIImageView *backImageView;

//播放／暂停
@property (nonatomic, strong) UIButton *playBtn;
//当前时间
@property (nonatomic, strong) UILabel *currentTime;
//视频总时间
@property (nonatomic, strong) UILabel *totalTime;
//全屏切换
@property (nonatomic, strong) UIButton *fullScreenBtn;
//播放进度
@property (nonatomic, strong) UISlider *progressSlide;

@end

@implementation JRPlayView

- (instancetype)initWithFrame:(CGRect)frame videoUrl:(NSString *)videoUrl isAutoReplay:(BOOL)isAutoReplay
{
    if (self == [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor blackColor];
        self.playFrame = frame;
        self.playBounds = self.bounds;
        self.isAutoReplay = isAutoReplay;
        self.isChangeToPlay = YES;//默认暂停
        
        //Cupid_高清   minion_02
        self.playerItem = [AVPlayerItem playerItemWithURL:[[NSBundle mainBundle] URLForResource:videoUrl withExtension:nil]];
        self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        self.playerLayer.frame = self.bounds;
        [self.layer addSublayer:self.playerLayer];
        
        self.bottomView = [[UIView alloc]initWithFrame:CGRectZero];
        self.bottomView.backgroundColor = [UIColor redColor];
        [self addSubview:self.bottomView];
        
        self.backImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        self.backImageView.image = [UIImage imageNamed:@"coverBg"];
        [self.bottomView addSubview:self.backImageView];
        
        //播放／暂停
        self.playBtn = [[UIButton alloc]initWithFrame:CGRectZero];
        [self.playBtn setBackgroundImage:[UIImage imageNamed:@"Play"] forState:UIControlStateNormal];
        [self.playBtn addTarget:self action:@selector(playBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomView addSubview:self.playBtn];
        
        //已播放时间
        self.currentTime = [[UILabel alloc]initWithFrame:CGRectZero];
        self.currentTime.text = @"00:00";
        self.currentTime.textAlignment = NSTextAlignmentCenter;
        [self.bottomView addSubview:self.currentTime];
        
        //播放进度
        self.progressSlide = [[UISlider alloc]initWithFrame:CGRectZero];
        [self.progressSlide setThumbImage:[UIImage imageNamed:@"Point"] forState:UIControlStateNormal];
        [self.progressSlide setMinimumTrackImage:[UIImage imageNamed:@"MinimumTrackImage"] forState:UIControlStateNormal];
        [self.progressSlide addTarget:self action:@selector(updateCurrentTime) forControlEvents:UIControlEventValueChanged];
        [self.bottomView addSubview:self.progressSlide];
        
        //视频总时间
        self.totalTime = [[UILabel alloc]initWithFrame:CGRectZero];
        self.totalTime.text = @"00:00";
        self.totalTime.textAlignment = NSTextAlignmentCenter;
        [self.bottomView addSubview:self.totalTime];

        //全屏切换
        self.fullScreenBtn = [[UIButton alloc]initWithFrame:CGRectZero];
        [self.fullScreenBtn setBackgroundImage:[UIImage imageNamed:@"FullScreen"] forState:UIControlStateNormal];
        [self.fullScreenBtn addTarget:self action:@selector(fullScreenBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomView addSubview:self.fullScreenBtn];
        
        //单击屏幕
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
        [self addGestureRecognizer:singleTap];
        
        //双击屏幕
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];
        
        //竖直滑动
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(gestureSlide:)];
        [self addGestureRecognizer:panGesture];
        
        //只有当没有检测到doubleTap 或者 检测doubleTap失败，singleTap才有效
        [singleTap requireGestureRecognizerToFail:doubleTap];
        //添加观察者和通知
        [self addNotification];
    }
    return self;
}

- (void)addNotification
{
    // 处理播放完成，自动循环播放
    if (self.isAutoReplay) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    }
    
    // 处理设备旋转
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];
}

/**
 *  播放完成通知
 *
 *  @param notification 通知对象
 */
-(void)playbackFinished:(NSNotification *)notification{
    NSLog(@"视频播放完成.");
    
    //CMTimeMake(a,b)  a当前第几帧, b每秒钟多少帧.当前播放时间a/b
    // 播放完成后，跳到最新的时间点重复播放
    [_player seekToTime:CMTimeMake(0, 1)];
    [_player play];
    [self.playBtn setBackgroundImage:[UIImage imageNamed:@"Pause"] forState:UIControlStateNormal];
    
    [self startTimer];
    [self updateTimeOnProgressAndTimeLabel];
}

//屏幕旋转
- (void)onDeviceOrientationChange
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortrait:
        {
            NSLog(@"竖直方向");
            self.frame = self.playFrame;
            self.playerLayer.frame = self.playBounds;
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
        {
            NSLog(@"水平方向");
            self.bounds = CGRectMake(0, 0, SCREENW, SCREENH);
            self.center = CGPointMake(SCREENW / 2, SCREENH / 2);
            self.playerLayer.bounds = CGRectMake(0, 0, SCREENW, SCREENH);
            self.playerLayer.position = CGPointMake(SCREENW / 2, SCREENH / 2);
        }
            break;
            
        default:
            break;
    }
}

/**
 *  强制屏幕转屏
 */
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = orientation;
        
        //从2开始是因为0 1 两个参数已经被selector和target占用
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}


//全屏/非全屏
- (void)fullScreenBtnAction
{
    _isChangeToFullScreen = !_isChangeToFullScreen;
    if (_isChangeToFullScreen) {
        [self interfaceOrientation:UIInterfaceOrientationLandscapeLeft];
    }else{
        [self interfaceOrientation:UIInterfaceOrientationPortrait];
    }
}

//播放/暂停
- (void)playBtnAction
{
    //当播放已结束，手动点击重复播放（非自动重复播放）
    if ((!self.isAutoReplay) && self.progressSlide.value == 1) {
        [self playbackFinished:nil];
        return;
    }
    
    //手动点击切换播放／暂停
    if (_isChangeToPlay) {
        _isChangeToPlay = NO;
        [self startTimer];
        [self.player play];
        [self.playBtn setBackgroundImage:[UIImage imageNamed:@"Pause"] forState:UIControlStateNormal];
        
        NSTimeInterval duration = CMTimeGetSeconds(self.player.currentItem.duration);
        self.totalTime.text = [self stringWithTime:duration];
    }else{
        _isChangeToPlay = YES;
        [self stopTimer];
        [self.player pause];
        [self.playBtn setBackgroundImage:[UIImage imageNamed:@"Play"] forState:UIControlStateNormal];
    }
}

- (void)updateTimeOnProgressAndTimeLabel {
    [self updateTimeOnProgress];
    [self updateTimeOnTimeLabel];
}

//刷新显示已播放时间的标签
- (void)updateTimeOnTimeLabel
{
    NSTimeInterval currentTime = CMTimeGetSeconds(self.player.currentTime);
    self.currentTime.text = [self stringWithTime:currentTime];
    NSTimeInterval duration = CMTimeGetSeconds(self.player.currentItem.duration);
    self.totalTime.text = [self stringWithTime:duration];
}

//刷新进度条
- (void)updateTimeOnProgress
{
    self.progressSlide.value = CMTimeGetSeconds(self.player.currentTime) / CMTimeGetSeconds(self.player.currentItem.duration);
    
    //播放结束时，切换播放按钮
    if ((self.progressSlide.value == 1) && !self.isAutoReplay) {
        _isChangeToPlay = NO;
        [self stopTimer];
        [self.playBtn setBackgroundImage:[UIImage imageNamed:@"Play"] forState:UIControlStateNormal];
    }
}

//当手动滑动进度条时，更新已播放时间
- (void)updateCurrentTime
{
    NSInteger currentTime = self.progressSlide.value * CMTimeGetSeconds(self.player.currentItem.duration);
    //设置当前播放时间
    [self.player seekToTime:CMTimeMakeWithSeconds(currentTime, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [self updateTimeOnTimeLabel];
    
    //播放结束时，切换播放按钮
    if (!self.isAutoReplay) {
        if ((self.progressSlide.value == 1)) {
            _isChangeToPlay = NO;
            [self stopTimer];
            [self.playBtn setBackgroundImage:[UIImage imageNamed:@"Play"] forState:UIControlStateNormal];
        }else{
             _isChangeToPlay = YES;
        }
    }
}

//单击手势：隐藏／显示底部工具栏
- (void)singleTap:(UITapGestureRecognizer *)singleTap
{
    if (singleTap.state == UIGestureRecognizerStateRecognized) {
        [self hideOrShowBottomView];
    }
}

//双击手势：全屏/非全屏
- (void)doubleTap:(UITapGestureRecognizer *)doubleTap
{
    if (doubleTap.state == UIGestureRecognizerStateRecognized) {
        [self fullScreenBtnAction];
    }
}

//垂直滑动手势：调节屏幕亮度
- (void)gestureSlide:(UIPanGestureRecognizer *)panGesture
{
    //根据上次和本次移动的位置，算速率
    CGPoint velocityPoint = [panGesture velocityInView:self];
    switch (panGesture.state) {
        case UIGestureRecognizerStateChanged:{
            //使用绝对值来判断移动的方向
            CGFloat x = fabs(velocityPoint.x);
            CGFloat y = fabs(velocityPoint.y);
            
            if (y>x) {//竖直方向移动
                [UIScreen mainScreen].brightness -= velocityPoint.y / 10000;;
              }else{//水平方向移动
                
            }
        }
            break;
        case UIGestureRecognizerStateEnded:{

        }
            break;
        default:
            break;
    }
}

- (void)startTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:.2f target:self selector:@selector(updateTimeOnProgressAndTimeLabel) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer
{
    [self.timer invalidate];
}

//隐藏/显示底部工具栏
- (void)hideOrShowBottomView
{
    _isHideBottomView = !_isHideBottomView;
    if (_isHideBottomView) {
        [self.bottomView removeFromSuperview];
    }else{
        [self addSubview:self.bottomView];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.bottomView.frame = CGRectMake(0, self.bounds.size.height - 44, self.width, 44);
    self.backImageView.frame = self.bottomView.bounds;
    
    self.playBtn.width = self.fullScreenBtn.width = BtnWH;
    self.currentTime.width = [self.currentTime jr_getTextWidth];
    self.totalTime.width = [self.totalTime jr_getTextWidth];
    
    self.playBtn.left = 5;
    self.currentTime.left = self.playBtn.right + 10;
    self.progressSlide.left = self.currentTime.right + 10;
    
    self.fullScreenBtn.right = self.width - 5;
    self.totalTime.right = self.fullScreenBtn.left - 10;
    
    self.progressSlide.width = (self.totalTime.left - 10) - (self.currentTime.right + 10);
    self.playBtn.height = self.fullScreenBtn.height = self.currentTime.height = self.totalTime.height = self.progressSlide.height = BtnWH;
    self.playBtn.top = self.fullScreenBtn.top = self.currentTime.top = self.totalTime.top = (self.bottomView.height - BtnWH) / 2;
    
    self.progressSlide.center = self.backImageView.center;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 私有工具方法

- (NSString *)stringWithTime:(NSTimeInterval)time {
    NSInteger dHour = time / 3600;
    NSInteger dMin = time / 60;
    NSInteger dSec = (NSInteger)time % 60;
    if (dHour) {
        return [NSString stringWithFormat:@"%02ld:%02ld:%02ld",dHour, dMin, dSec];
    }else{
        return [NSString stringWithFormat:@"%02ld:%02ld", dMin, dSec];
    }
}


@end
