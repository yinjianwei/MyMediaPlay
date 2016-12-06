//
//  Macros.h
//  MyMediaPlay
//
//  Created by Yinjw on 16/9/12.
//  Copyright © 2016年 Yinjw. All rights reserved.
//

#ifndef Macros_h
#define Macros_h

#define MyLong unsigned long

#define SWITCH_VIEW(oldViewController, newViewController, showTabBar)   do{\
        BOOL originShow = [oldViewController hidesBottomBarWhenPushed];  \
        [oldViewController setHidesBottomBarWhenPushed:!showTabBar];     \
        [oldViewController.navigationController pushViewController:newViewController animated:YES]; \
        [oldViewController setHidesBottomBarWhenPushed:originShow]; \
    }while(0)

#endif /* Macros_h */
