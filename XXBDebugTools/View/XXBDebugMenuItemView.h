//
//  XXBDebugMenuItem.h
//  XXBDebugToolsDemo
//
//  Created by xiaobing5 on 2018/4/26.
//  Copyright © 2018年 xiaobing5. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XXBDebugMenuItemView;

#define XXBDEBUGMENUITEM_EDGE_WIDTH      6   // 边缘宽度(文字与菜单项的间距)
#define XXBDEBUGMENUITEM_BKIMAGE_EDGE    15  // 背景图片边缘宽度
#define XXBDEBUGMENUITEM_ANIMATION_TIME  0.16    // 菜单项弹出/收起动画时间

@protocol XXBDebugMenuItemViewDelegate <NSObject>

- (void)menuItemDidClicked:(XXBDebugMenuItemView *)item;
@end

@interface XXBDebugMenuItemView : UIView

/** 委托对象 */
@property (nonatomic, weak) id<XXBDebugMenuItemViewDelegate>            delegate;

/** 菜单ID */
@property (nonatomic, copy) NSString                                *identifier;

/** 是否在屏幕锁定(点击子菜单项后不收起), 默认NO */
@property (nonatomic, assign) BOOL                                  locked;

/** 子菜单 */
@property (nonatomic, readonly) NSMutableArray <XXBDebugMenuItemView *> *subItems;

/** 父菜单 */
@property (nonatomic, weak) XXBDebugMenuItemView                        *parentItem;

/** 点击事件回调 */
@property (nonatomic, copy) void (^clickBlock)(NSString *);

/** 最大宽度 */
@property (nonatomic, assign) CGFloat                               maxWidth;

/** 最小宽度 */
@property (nonatomic, assign) CGFloat                               minWidth;

/** 高亮状态 */
@property (nonatomic, assign) BOOL                                  highlighted;

/** 选中状态 */
@property (nonatomic, assign) BOOL                                  checked;

/** 标题文本 */
@property (nonatomic, copy) NSString                                *title;

/** 标题颜色 */
@property (nonatomic, strong) UIColor                               *titleColor;

/** 背景颜色 */
@property (nonatomic, strong) UIColor                               *bkgndColor;

/** 是否正在显示 */
@property (nonatomic, readonly) BOOL                                onShow;

/** 展开菜单项 */
- (void)openMenuItemFromPoint:(CGPoint)ptFrom toPoint:(CGPoint)ptEnd;

/** 关闭菜单项 */
- (void)closeMenuItem;

/** 获取指定id的子菜单 */
- (XXBDebugMenuItemView *)subitemWithID:(NSString *)identifier;

/** 移除指定id的子菜单 */
- (BOOL)removeSubitemWithID:(NSString *)identifier;

/** 添加一个子菜单 */
- (void)addSubitem:(XXBDebugMenuItemView *)subitem;

/** 取消所有子菜单的选中状态 */
- (void)uncheckAllSubitems;

@end
