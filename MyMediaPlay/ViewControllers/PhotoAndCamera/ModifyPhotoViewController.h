//
//  ModifyPhotoViewController.h
//  MyMediaPlay
//
//  Created by Yinjw on 2016/12/6.
//  Copyright © 2016年 Yinjw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "ValueSliderView.h"

@interface ModifyPhotoViewController : BaseViewController <ValueSliderViewDelegate>

-(instancetype)initWithImage:(UIImage*)photoImage;

@end
