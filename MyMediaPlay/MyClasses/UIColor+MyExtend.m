//
//  UIColor+MyExtend.m
//  MyMediaPlay
//
//  Created by Yinjw on 16/9/12.
//  Copyright © 2016年 Yinjw. All rights reserved.
//

#import "UIColor+MyExtend.h"
#import "Macros.h"

@implementation UIColor(MyExtend)

+(UIColor*)colorWithHexValue:(NSString*)hexValue
{
    NSInteger startIndex = 0;
    if([[hexValue substringToIndex:1] isEqualToString:@"#"])
    {
        startIndex = 1;
    }
    NSString* a = [hexValue substringWithRange:NSMakeRange(startIndex, 2)];
    NSString* r = [hexValue substringWithRange:NSMakeRange(startIndex+2, 2)];
    NSString* g = [hexValue substringWithRange:NSMakeRange(startIndex+4, 2)];
    NSString* b = [hexValue substringWithRange:NSMakeRange(startIndex+6, 2)];
    UIColor* color = [UIColor colorWithRed:[UIColor convertStringToHexNumber:r]/255.0 green:[UIColor convertStringToHexNumber:g]/255.0 blue:[UIColor convertStringToHexNumber:b]/255.0 alpha:[UIColor convertStringToHexNumber:a]/255.0];
    return color;
}

+(MyLong)convertStringToHexNumber:(NSString*)hexValue
{
    NSString* convertStr = hexValue;
    if(![[hexValue substringToIndex:2] isEqualToString:@"0x"])
    {
        convertStr = [NSString stringWithFormat:@"0x%@", hexValue];
    }
    MyLong hexNumber = strtoul([convertStr UTF8String], nil, 0);
    return hexNumber;
}

@end
