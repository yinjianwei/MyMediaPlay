//
//  VideoPlayerViewController.m
//  MyAudioPlay
//
//  Created by Yinjw on 16/9/8.
//  Copyright © 2016年 Yinjw. All rights reserved.
//

#import "VideoPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "CustomVideoPlayLayer.h"

@interface VideoPlayerViewController ()

@property(nonatomic, strong)AVPlayerViewController* videoPlayer;

@end

@implementation VideoPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITableView* tableView = [[UITableView alloc] init];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tableFooterView = [[UIView alloc] init];
    tableView.rowHeight = 40;
    [self.view addSubview:tableView];
    [tableView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

-(void)playVideoByIndex:(NSUInteger)index
{
    NSString* urlStr = [[NSBundle mainBundle] pathForResource:@"lion" ofType:@"mp4"];
//    self.videoPlayer = [[AVPlayerViewController alloc] init];
//    self.videoPlayer.player = [[AVPlayer alloc] initWithPlayerItem:[[AVPlayerItem alloc] initWithURL:[NSURL fileURLWithPath:urlStr]]];
//    [self presentViewController:self.videoPlayer animated:YES completion:nil];
    
    CustomVideoPlayLayer* videoPlayer = [[CustomVideoPlayLayer alloc] initVideoPlayerWithFilePath:urlStr];
    [self.navigationController pushViewController:videoPlayer animated:YES];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"videoCell"];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"videoCell"];
    }
    cell.textLabel.text = @"lion";
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self playVideoByIndex:indexPath.row];
}

@end
