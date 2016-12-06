//
//  ValueSliderView.h
//  MyMediaPlay
//
//  Created by Yinjw on 2016/12/6.
//  Copyright © 2016年 Yinjw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ValueSliderViewDelegate <NSObject>

-(void)updateSliderValue:(CGFloat)value valueKey:(NSString*)valueKey;

@end

@interface ValueSliderView : UIView

@property(nonatomic, weak, nullable)id<ValueSliderViewDelegate> delegate;
@property(nonatomic, strong)NSString*       valueKey;   //用于记录修改的属性名称

-(instancetype)initWithTitle:(NSString*)title value:(CGFloat)value minValue:(CGFloat)minValue maxValue:(CGFloat)maxValue;

@end

NS_ASSUME_NONNULL_END
