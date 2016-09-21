//
//  UIColor+MyExtend.h
//  MyMediaPlay
//
//  Created by Yinjw on 16/9/12.
//  Copyright © 2016年 Yinjw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIColor(MyExtend)

//字符串的16进制值(ARGB)，例如@“#FF889832”或者@"FF123456"
+(UIColor*)colorWithHexValue:(NSString*)hexValue;

@end
