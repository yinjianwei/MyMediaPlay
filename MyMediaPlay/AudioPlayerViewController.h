//
//  MainPlayerViewController.h
//  MyAudioPlay
//
//  Created by Yinjw on 16/9/8.
//  Copyright © 2016年 Yinjw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "BaseViewController.h"

@interface AudioPlayerViewController : BaseViewController <AVAudioPlayerDelegate, UITableViewDelegate, UITableViewDataSource>

-(void)updateLockScreenInfo;

@end
