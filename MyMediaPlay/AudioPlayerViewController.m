//
//  MainPlayerViewController.m
//  MyAudioPlay
//
//  Created by Yinjw on 16/9/8.
//  Copyright © 2016年 Yinjw. All rights reserved.
//

#import "AudioPlayerViewController.h"
#import "UIColor+MyExtend.h"
#import "AudioData.h"
#import <MediaPlayer/MediaPlayer.h>

@interface AudioPlayerViewController ()

@property(nonatomic, strong)UIImageView*        musicImage;
@property(nonatomic, strong)UITableView*        audioPlayListTableView;
@property(nonatomic, strong)UIButton*           playAndPauseButton;
@property(nonatomic, strong)UISlider*           progressSlider;

@property(nonatomic, strong)AVAudioPlayer*      currentAudioPlayer;
@property(nonatomic, strong)NSTimer*            progressTimer;

@property(nonatomic, strong)NSMutableArray<AudioData*>*     audioPlayList;
@property(nonatomic)NSInteger                   playIndex;

@end

@implementation AudioPlayerViewController

-(void)dealloc
{
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"音频播放";
    self.view.backgroundColor = [UIColor whiteColor];
//    self.automaticallyAdjustsScrollViewInsets = NO;
//    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.audioPlayList = [[NSMutableArray alloc] init];
    self.playIndex = 0;
    
    [self setupUI];
    [self initAudioPlayList];
}

-(void)viewDidAppear:(BOOL)animated
{
    self.progressTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.progressTimer forMode:NSDefaultRunLoopMode];
    [self.progressTimer fire];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLockScreenInfo) name:@"enterBackground" object:nil];
    
    [super viewDidAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.progressTimer invalidate];
    self.progressTimer = NULL;
    
    [self.currentAudioPlayer pause];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setupUI
{
    UIView* audioView = [[UIView alloc] init];
    [self.view addSubview:audioView];
    [audioView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.musicImage = [[UIImageView alloc] init];
    self.musicImage.image = [UIImage imageNamed:@"person"];
    self.musicImage.userInteractionEnabled = YES;
    [self.musicImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onMusicImageTap:)]];
    [audioView addSubview:self.musicImage];
    [self.musicImage makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(audioView).offset(20);
        make.centerX.equalTo(audioView);
    }];
    
    self.audioPlayListTableView = [[UITableView alloc] init];
    self.audioPlayListTableView.backgroundColor = [UIColor colorWithHexValue:@"#30FFFF00"];
    self.audioPlayListTableView.delegate = self;
    self.audioPlayListTableView.dataSource = self;
    self.audioPlayListTableView.rowHeight = 40;
    self.audioPlayListTableView.tableFooterView = [[UIView alloc] init];
    self.audioPlayListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [audioView addSubview:self.audioPlayListTableView];
    [self.audioPlayListTableView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.musicImage.bottom).offset(10);
        make.left.equalTo(audioView).offset(15);
        make.right.equalTo(audioView).offset(-15);
        make.height.equalTo(160);
    }];
    
    self.progressSlider = [[UISlider alloc] init];
    [self.progressSlider addTarget:self action:@selector(endDragSlider:) forControlEvents:UIControlEventTouchUpInside];
    [audioView addSubview:self.progressSlider];
    [self.progressSlider makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.audioPlayListTableView.bottom).offset(10);
        make.left.equalTo(audioView).offset(25);
        make.right.equalTo(audioView).offset(-25);
    }];
    
    //控制按钮区域
    UIView* controlView = [[UIView alloc] init];
    controlView.backgroundColor = [UIColor colorWithHexValue:@"30222222"];
    [audioView addSubview:controlView];
    [controlView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.progressSlider.bottom).offset(20);
        make.left.right.equalTo(self.audioPlayListTableView);
        make.bottom.equalTo(audioView).offset(-20);
    }];
    
    self.playAndPauseButton = [[UIButton alloc] init];
    [self.playAndPauseButton setImage:[UIImage imageNamed:@"button-play"] forState:UIControlStateNormal];
    [self.playAndPauseButton addTarget:self action:@selector(onPlayButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [controlView addSubview:self.playAndPauseButton];
    [self.playAndPauseButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(controlView).offset(5);
        make.centerX.equalTo(controlView);
        make.bottom.equalTo(controlView).offset(-5);
    }];
    
    UIButton* speedUpButton = [[UIButton alloc] init];
    [speedUpButton setImage:[UIImage imageNamed:@"button-fast-forward"] forState:UIControlStateNormal];
    [speedUpButton addTarget:self action:@selector(onPlayFastButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [controlView addSubview:speedUpButton];
    [speedUpButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(controlView).offset(5);
        make.left.equalTo(self.playAndPauseButton.right).offset(15);
        make.bottom.equalTo(controlView).offset(-5);
    }];
    
    UIButton* slowButton = [[UIButton alloc] init];
    [slowButton setImage:[UIImage imageNamed:@"button-fast-rewind"] forState:UIControlStateNormal];
    [slowButton addTarget:self action:@selector(onPlaySlowButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [controlView addSubview:slowButton];
    [slowButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(controlView).offset(5);
        make.right.equalTo(self.playAndPauseButton.left).offset(-15);
        make.bottom.equalTo(controlView).offset(-5);
    }];
    
    UIButton* nextButton = [[UIButton alloc] init];
    [nextButton setImage:[UIImage imageNamed:@"button-next"] forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(onPlayNextButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [controlView addSubview:nextButton];
    [nextButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(controlView).offset(5);
        make.left.equalTo(speedUpButton.right).offset(15);
        make.bottom.equalTo(controlView).offset(-5);
    }];
    
    UIButton* prevButton = [[UIButton alloc] init];
    [prevButton setImage:[UIImage imageNamed:@"button-previous"] forState:UIControlStateNormal];
    [prevButton addTarget:self action:@selector(onPlayPrevButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [controlView addSubview:prevButton];
    [prevButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(controlView).offset(5);
        make.right.equalTo(slowButton.left).offset(-15);
        make.bottom.equalTo(controlView).offset(-5);
    }];
}

-(void)initAudioPlayList
{
    for(int i = 0;i < 20;i++)
    {
        AudioData* data = [[AudioData alloc] init];
        data.name = @"微微一笑很倾城";
        data.fileName = @"杨洋 - 微微一笑很倾城";
        [self.audioPlayList addObject:data];
    }
}

-(void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    if(!self.currentAudioPlayer)
        return;
    
    if(event.type==UIEventTypeRemoteControl){
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlPlay:
                [self playCurrentAudio];
                break;
            case UIEventSubtypeRemoteControlPause:
                [self pauseCurrentAudio];
                break;
            case UIEventSubtypeRemoteControlTogglePlayPause:
                if(self.currentAudioPlayer.isPlaying)
                {
                    [self pauseCurrentAudio];
                }
                else
                {
                    [self playCurrentAudio];
                }
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                [self onPlayNextButtonEvent:nil];
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                [self onPlayPrevButtonEvent:nil];
                break;
            case UIEventSubtypeRemoteControlBeginSeekingForward:
                [self onPlayFastButtonEvent:nil];
                break;
            case UIEventSubtypeRemoteControlEndSeekingForward:
                [self recoverNormalPlaySpeed];
                break;
            case UIEventSubtypeRemoteControlBeginSeekingBackward:
                [self onPlaySlowButtonEvent:nil];
                break;
            case UIEventSubtypeRemoteControlEndSeekingBackward:
                [self recoverNormalPlaySpeed];
                break;
            default:
                break;
        }
    }
}

#pragma mark - AVAudioPlayDelegate

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self onPlayNextButtonEvent:nil];
}

#pragma mark - button event

-(void)onPlayButtonEvent:(id)sender
{
    if(!self.currentAudioPlayer)
    {
        [self createCurrentAudioByIndex:self.playIndex];
    }
    
    if(self.currentAudioPlayer.isPlaying)
    {
        [self pauseCurrentAudio];
    }
    else
    {
        [self playCurrentAudio];
    }
}

-(void)onPlayFastButtonEvent:(id)sender
{
    self.currentAudioPlayer.rate += 0.5;
}

-(void)onPlaySlowButtonEvent:(id)sender
{
    self.currentAudioPlayer.rate -= 0.5;
}

-(void)onPlayNextButtonEvent:(id)sender
{
    if(self.currentAudioPlayer)
    {
        [self.currentAudioPlayer stop];
    }
    
    NSInteger oldPlayIndex = self.playIndex;
    
    self.playIndex++;
    self.playIndex = self.playIndex >= self.audioPlayList.count ? 0 : self.playIndex;
    
    [self createCurrentAudioByIndex:self.playIndex];
    [self playCurrentAudio];
    
    NSIndexPath* oldIndexPath = [NSIndexPath indexPathForRow:oldPlayIndex inSection:0];
    NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow:self.playIndex inSection:0];
    [self.audioPlayListTableView reloadRowsAtIndexPaths:@[oldIndexPath, newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    //播放完切换到下一首时，UITableView自动滚动
    //方案一
    CGRect rect = [self.audioPlayListTableView rectForRowAtIndexPath:newIndexPath];
    if((rect.origin.y - self.audioPlayListTableView.contentOffset.y >= self.audioPlayListTableView.frame.size.height) ||
       (rect.origin.y <= self.audioPlayListTableView.contentOffset.y))
    {
        [self.audioPlayListTableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
    
    //方案二
//    NSArray* visibleAry = [self.audioPlayListTableView indexPathsForVisibleRows];
//    if([visibleAry indexOfObject:newIndexPath] == NSNotFound)
//    {
//        [self.audioPlayListTableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
//    }
}

-(void)onPlayPrevButtonEvent:(id)sender
{
    if(self.currentAudioPlayer)
    {
        [self.currentAudioPlayer stop];
    }
    
    NSInteger oldPlayIndex = self.playIndex;
    
    self.playIndex--;
    self.playIndex = self.playIndex < 0 ? self.audioPlayList.count-1 : self.playIndex;
    
    [self createCurrentAudioByIndex:self.playIndex];
    [self playCurrentAudio];
    
    [self.audioPlayListTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:oldPlayIndex inSection:0],
                                                          [NSIndexPath indexPathForRow:self.playIndex inSection:0]]
                                       withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - UIPanGestureRecognizer

-(void)onMusicImageTap:(id)sender
{
    [UIView animateWithDuration:2.0 animations:^{
        self.musicImage.layer.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
    } completion:^(BOOL finished) {
        NSLog(@"animation done");
    }];
}

#pragma mark - Event process

//UIControlEventTouchUpInSide
-(void)endDragSlider:(id)sender
{
    NSTimeInterval currentTime = self.currentAudioPlayer.duration * self.progressSlider.value;
    self.currentAudioPlayer.currentTime = currentTime;
}

#pragma mark - NSTimer

-(void)updateProgress
{
    if(!self.currentAudioPlayer)
        return;
    
    if(self.progressSlider.touchInside)
        return;
    
    float progress = self.currentAudioPlayer.currentTime / self.currentAudioPlayer.duration;
    [self.progressSlider setValue:progress animated:YES];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.audioPlayList.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"playListCell"];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"playListCell"];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if(indexPath.row == self.playIndex)
    {
        cell.textLabel.textColor = [UIColor colorWithHexValue:@"#FFFF0000"];
    }
    else
    {
        cell.textLabel.textColor = [UIColor colorWithHexValue:@"#FF666666"];
    }
    AudioData* data = [self.audioPlayList objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld.%@", indexPath.row+1, data.name];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* oldCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.playIndex inSection:0]];
    oldCell.textLabel.textColor = [UIColor colorWithHexValue:@"#FF666666"];
    
    UITableViewCell* newCell = [tableView cellForRowAtIndexPath:indexPath];
    newCell.textLabel.textColor = [UIColor colorWithHexValue:@"#FFFF0000"];
    
    self.playIndex = indexPath.row;
    
    [self createCurrentAudioByIndex:indexPath.row];
    [self playCurrentAudio];
}

#pragma mark - public medthod

-(void)updateLockScreenInfo
{
    [self setLockScreenInfo];
}

#pragma mark - self method

-(AVAudioPlayer*)createAudioPlayerByFile:(NSString*)fileName
{
    NSURL* url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:fileName ofType:@"mp3"]];
    NSError* error = nil;
    AVAudioPlayer* audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    audioPlayer.numberOfLoops = 0;
    audioPlayer.enableRate = YES;
    audioPlayer.delegate = self;
    [audioPlayer prepareToPlay];
    if(error)
    {
        NSLog(@"init audioplay error!");
        return nil;
    }
    
    return audioPlayer;
}

-(void)createCurrentAudioByIndex:(NSUInteger)index
{
    if(index >= self.audioPlayList.count)
        return;
    
    NSString* fileName = [self.audioPlayList objectAtIndex:index].fileName;
    self.currentAudioPlayer = [self createAudioPlayerByFile:fileName];
    if(!self.currentAudioPlayer)
    {
        NSLog(@"create audioPlayer failed! fileName=%@", fileName);
        return;
    }
}

-(void)playCurrentAudio
{
    if(!self.currentAudioPlayer)
        return;
    
    [self.currentAudioPlayer play];
    [self.playAndPauseButton setImage:[UIImage imageNamed:@"button-pause"] forState:UIControlStateNormal];
}

-(void)pauseCurrentAudio
{
    if(!self.currentAudioPlayer)
        return;
    
    [self.currentAudioPlayer pause];
    [self.playAndPauseButton setImage:[UIImage imageNamed:@"button-play"] forState:UIControlStateNormal];
}

-(void)recoverNormalPlaySpeed
{
    if(!self.currentAudioPlayer)
        return;
    
    self.currentAudioPlayer.rate = 1.0f;
}

-(void)setLockScreenInfo
{
    MPMediaItemArtwork* artWork = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:@"person"]];
    NSDictionary* dict = @{MPMediaItemPropertyTitle:@"微微一笑很倾城",
                           MPMediaItemPropertyArtist:@"杨洋",
                           MPMediaItemPropertyArtwork:artWork,
                           MPMediaItemPropertyRating:@(self.currentAudioPlayer.rate),
                           MPMediaItemPropertyPlaybackDuration:@(self.currentAudioPlayer.duration)};
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
}

@end
