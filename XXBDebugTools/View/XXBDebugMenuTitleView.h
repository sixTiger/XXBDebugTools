//
//  XXBDebugMenuTitle.h
//  XXBDebugToolsDemo
//
//  Created by xiaobing5 on 2018/4/26.
//  Copyright © 2018年 xiaobing5. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XXBDebugMenuTitleView;

@protocol XXBDebugMenuTitleViewDelegate <NSObject>

/**
 点击标题

 @param title 点击的标题
 */
- (void)debugMenuTitleDidClick:(XXBDebugMenuTitleView *)title;
@end

@interface XXBDebugMenuTitleView : UIView

@property (nonatomic, weak) id<XXBDebugMenuTitleViewDelegate>   delegate;

/**
 最大宽度
 */
@property (nonatomic, assign) CGFloat                           maxWidth;

/**
 选中状态
 */
@property (nonatomic, assign) BOOL                              selected;

/**
 文本内容
 */
@property (nonatomic, copy) NSString                            *text;

/**
 字体
 */
@property (nonatomic, strong) UIFont                            *font;

/**
 是否反向设置位置(显示在距离屏幕边缘较近的位置)
 */
@property (nonatomic, assign) BOOL                              revertPosition;

/**
 显示

 @param point 显示在对应的点
 */
- (void)showFromPoint:(CGPoint)point;

/**
 隐藏
 */
- (void)hide;
@end
