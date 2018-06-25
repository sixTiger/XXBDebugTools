//
//  XXBDebugPopMenu.h
//  XXBDebugToolsDemo
//
//  Created by xiaobing5 on 2018/4/26.
//  Copyright © 2018年 xiaobing5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XXBDebugMainWindow.h"

@class XXBDebugPopMenu;

@protocol XXBDebugPopMenuDelegate <NSObject>
- (void)debugPopMenuWillShow:(XXBDebugPopMenu *)menu;
- (void)debugPopMenuWillDisappear:(XXBDebugPopMenu *)menu;
- (void)debugPopMenuDidLockMenu:(NSString *)parentID locked:(BOOL)lock;
@end

@interface XXBDebugPopMenu : NSObject

/** 菜单弹出视图 */
@property (nonatomic, weak) XXBDebugMainWindow              *superView;

/** 委托对象 */
@property (nonatomic, weak) id<XXBDebugPopMenuDelegate>     delegate;

/** 是否已弹出 */
@property (nonatomic, readonly) BOOL                        poped;

/** 当前菜单标题 */
@property (nonatomic, readonly) NSString                    *currentMenuTitle;

/** 当前菜单组的锁定状态 */
@property (nonatomic, readonly) BOOL                        currentMenuLocked;

/** 当前菜单是否是根菜单 */
@property (nonatomic, readonly) BOOL                        isRootMenu;

/** 弹出菜单 */
- (void)popFromPoint:(CGPoint)point;

/** 收起菜单 */
- (void)unpop;

/** 若当前菜单组未锁定则收起 */
- (void)unpopIfUnlocked;

/** 暂时收起菜单, 下次弹出时使用当前菜单级别 */
- (void)unpopForTemp;

/** 恢复菜单 */
- (void)recoverPopFromPoint:(CGPoint)point;

/** 返回到上一级菜单 */
- (void)returnToUplevel;

/** 切换当前菜单组的锁定状态 */
- (void)switchCurrentMenuLockStatus;

/** 切换弹出状态 */
- (void)switchPopOfPoint:(CGPoint)point;

/** 添加一个菜单项 */
- (BOOL)addMenuItemWithID:(NSString *)identifier parentItem:(NSString *)parentID title:(NSString *)title action:(void(^)(NSString *buttonID))onClickBlock;

/** 移除一个菜单项 */
- (void)removeMenuItemWithID:(NSString *)identifier;

/** 设置菜单项选中态 */
- (void)checkMenuItemWithID:(NSString *)identifier check:(BOOL)check;

/** 将指定id的按钮移动到同组按钮的顶部 */
- (BOOL)bringMenuToTop:(NSString *)identifier;

/** 将指定id的按钮移动到同组按钮的底部 */
- (BOOL)bringMenuToBottom:(NSString *)identifier;

/** 设置菜单项文本 */
- (void)setMenuItemText:(NSString *)text forItemWithID:(NSString *)identifier;

/** 取消选中指定父级菜单的所有子菜单 */
- (void)uncheckMenuItemWithParentID:(NSString *)parentIdentifier;

/** 锁定当前菜单组(点选后不收起) */
- (void)lockCurrentButtons:(BOOL)locked;

/** 锁定指定菜单(点选子菜单后不收起) */
- (void)setButtonLock:(BOOL)locked forButtonWithID:(NSString *)identifier;

/** 是否有指定id的功能按钮 */
- (BOOL)hasFunctionWithID:(NSString *)identifier;

/** 设置菜单标题颜色 */
- (void)setMenuItemTextColor:(UIColor *)color forItemWithID:(NSString *)identifier;

/** 设置菜单背景色 */
- (void)setMenuItemBkgndColor:(UIColor *)color forItemWithID:(NSString *)identifier;

/** 弹出指定菜单项 */
- (void)popParentMenu:(NSString *)identifier fromPoint:(CGPoint)point;
@end
