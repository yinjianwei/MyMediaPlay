//
//  BottomMenuView.h
//  MyMediaPlay
//
//  Created by Yinjw on 2016/10/13.
//  Copyright © 2016年 Yinjw. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BottomMenuViewDelegate <NSObject>

-(void)onClickMenu:(NSUInteger)menuIndex;

@end

@interface BottomMenuView : UIView

@property(nonatomic, weak)id<BottomMenuViewDelegate>    delegate;

-(instancetype)initWithMenuTitles:(NSArray*)titles;

@end
