//
//  ValueSliderView.m
//  MyMediaPlay
//
//  Created by Yinjw on 2016/12/6.
//  Copyright © 2016年 Yinjw. All rights reserved.
//

#import "ValueSliderView.h"

@implementation ValueSliderView

-(instancetype)initWithTitle:(NSString *)title value:(CGFloat)value minValue:(CGFloat)minValue maxValue:(CGFloat)maxValue
{
    self = [super init];
    if(self)
    {
        [self setupUIWithTitle:title value:value minValue:minValue maxValue:maxValue];
    }
    return self;
}

-(void)setupUIWithTitle:(NSString*)title value:(CGFloat)value minValue:(CGFloat)minValue maxValue:(CGFloat)maxValue
{
    UILabel* titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont systemFontOfSize:14];
    [self addSubview:titleLabel];
    [titleLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(15);
        make.centerY.equalTo(self);
    }];
    
    UISlider* slider = [[UISlider alloc] init];
    slider.value = value;
    slider.minimumValue = minValue;
    slider.maximumValue = maxValue;
    [slider addTarget:self action:@selector(updateSliderValue:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:slider];
    [slider makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleLabel.mas_right).offset(5);
        make.right.equalTo(self).offset(-15);
        make.top.bottom.equalTo(self);
    }];
}

-(void)updateSliderValue:(id)sender
{
    UISlider* slider = (UISlider*)sender;
    if(self.delegate && [self.delegate respondsToSelector:@selector(updateSliderValue:valueKey:)])
    {
        [self.delegate updateSliderValue:slider.value valueKey:self.valueKey];
    }
}

@end
