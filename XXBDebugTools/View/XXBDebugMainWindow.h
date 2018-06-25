//
//  XXBDebugMainWindow.h
//  XXBDebugToolsDemo
//
//  Created by xiaobing5 on 2018/4/25.
//  Copyright © 2018年 xiaobing5. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XXBDebugMainWindow : UIWindow

/**
 添加debug控件

 @param subview 要添加得控件
 */
- (void)addDebugComponent:(UIView *)subview;
@end
