//
//  CustomVideoPlayLayer.m
//  MyMediaPlay
//
//  Created by Yinjw on 16/9/29.
//  Copyright © 2016年 Yinjw. All rights reserved.
//

#import "CustomVideoPlayLayer.h"
#import <AVFoundation/AVFoundation.h>

@interface CustomVideoPlayLayer ()

@property(nonatomic, strong)UIView*         videoView;
@property(nonatomic, strong)UIView*         controlView;
@property(nonatomic, strong)UISlider*       progressSlider;
@property(nonatomic, strong)NSMutableArray* videoPlayList;

@property(nonatomic, strong)AVPlayer*       currentAVPlayer;
@property(nonatomic, strong)NSTimer*        progressTimer;

@property(nonatomic)BOOL                    isFullScreen;

@end

@implementation CustomVideoPlayLayer

-(instancetype)initVideoPlayerWithFilePath:(NSString *)filePath
{
    self = [super init];
    if(self)
    {
        self.videoPlayList = [NSMutableArray array];
        [self.videoPlayList addObject:filePath];
        self.isFullScreen = NO;
    }
    return self;
}

-(void)dealloc
{
    [self removePlayerItemObserver:self.currentAVPlayer.currentItem];
}

-(void)viewDidAppear:(BOOL)animated
{
    self.progressTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(updateProgressTimer) userInfo:NULL repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.progressTimer forMode:NSDefaultRunLoopMode];
    [self.progressTimer fire];
    
    [super viewDidAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.progressTimer invalidate];
    self.progressTimer = NULL;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupUI];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self playVideo];
    });
}

-(void)setupUI
{
    self.videoView = [[UIView alloc] init];
    self.videoView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.videoView];
    [self.videoView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.right.equalTo(self.view);
        make.height.equalTo(240);
    }];
    
    self.controlView = [[UIView alloc] init];
    self.controlView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:self.controlView];
    [self.controlView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.videoView.bottom).offset(10);
        make.left.right.equalTo(self.view);
        make.height.equalTo(140);
    }];
    
    self.progressSlider = [[UISlider alloc] init];
    [self.progressSlider addTarget:self action:@selector(dragSliderEnd:) forControlEvents:UIControlEventTouchUpInside];
    [self.controlView addSubview:self.progressSlider];
    [self.progressSlider makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.controlView).offset(5);
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
    }];
    
    UIButton* fullScreenButton = [[UIButton alloc] init];
    [fullScreenButton setTitle:@"全屏" forState:UIControlStateNormal];
    [fullScreenButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [fullScreenButton.layer setCornerRadius:5];
    [fullScreenButton.layer setBorderWidth:1];
    [fullScreenButton addTarget:self action:@selector(onBtnFullScreen:) forControlEvents:UIControlEventTouchUpInside];
    [self.controlView addSubview:fullScreenButton];
    [fullScreenButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.progressSlider.bottom).offset(10);
        make.right.equalTo(self.controlView).offset(-20);
        make.width.equalTo(40);
        make.height.equalTo(30);
    }];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
//    AVPlayerItem* playerItem = (AVPlayerItem*)object;
    if([keyPath isEqualToString:@"status"])
    {
        AVPlayerStatus status = [[change objectForKey:@"new"] intValue];
        if(status == AVPlayerStatusReadyToPlay)
        {
            [self.currentAVPlayer play];
        }
    }
}

-(void)updateViewConstraints
{
    if(self.isFullScreen)
    {
        self.controlView.hidden = true;
        self.videoView.transform = CGAffineTransformRotate(self.videoView.transform, M_PI_2);
        [self.videoView updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.view.height);
            make.width.equalTo(self.view.width);
        }];
    }
    
    [super updateViewConstraints];
}

#pragma mark - timer event

-(void)updateProgressTimer
{
    if(!self.currentAVPlayer || !self.currentAVPlayer.currentItem)
        return;
    
    float currentTime = self.currentAVPlayer.currentItem.currentTime.value / self.currentAVPlayer.currentItem.currentTime.timescale;
    float progress = currentTime / (self.currentAVPlayer.currentItem.duration.value / self.currentAVPlayer.currentItem.duration.timescale);
    [self.progressSlider setValue:progress animated:YES];
}

#pragma mark - UISlider event process

-(void)dragSliderEnd:(id)sender
{
    UISlider* slider = (UISlider*)sender;
    float curSecondsValue = slider.value * self.currentAVPlayer.currentItem.duration.value / self.currentAVPlayer.currentItem.duration.timescale;
    CMTime curTime = CMTimeMake(curSecondsValue * self.currentAVPlayer.currentItem.duration.timescale, self.currentAVPlayer.currentItem.duration.timescale);
    [self.currentAVPlayer seekToTime:curTime];
}

#pragma mark - UIButton event

-(void)onBtnFullScreen:(id)sender
{
    self.isFullScreen = YES;
    
    [self.view setNeedsUpdateConstraints];
    [self.view updateConstraintsIfNeeded];
    
}

#pragma mark - self method

-(void)addPlayerItemObserver:(AVPlayerItem *)playerItem
{
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监控网络加载情况属性
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
}

-(void)removePlayerItemObserver:(AVPlayerItem *)playerItem
{
    [playerItem removeObserver:self forKeyPath:@"status"];
    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}

-(void)playVideo
{
    if(self.videoPlayList.count < 1)
        return;
    
    if(self.currentAVPlayer)
    {
        [self removePlayerItemObserver:self.currentAVPlayer.currentItem];
    }
    
    NSURL* url = [NSURL fileURLWithPath:[self.videoPlayList objectAtIndex:0]];
    AVPlayerItem* item = [AVPlayerItem playerItemWithURL:url];
    AVPlayer* avplayer = [AVPlayer playerWithPlayerItem:item];
    AVPlayerLayer* videoPlayer = [AVPlayerLayer playerLayerWithPlayer:avplayer];
    videoPlayer.videoGravity = AVLayerVideoGravityResizeAspect;
    videoPlayer.frame = self.videoView.frame;
    [self.videoView.layer addSublayer:videoPlayer];
    self.currentAVPlayer = avplayer;
    
    [self addPlayerItemObserver:item];
}

@end
