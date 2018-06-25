//
//  XXBDebugConsole.m
//  XXBDebugToolsDemo
//
//  Created by xiaobing5 on 2018/4/25.
//  Copyright © 2018年 xiaobing5. All rights reserved.
//

#import "XXBDebugConsole.h"
#import "XXBDebugMainWindow.h"
#import "XXBDebugConsoleMainButton.h"
#import "XXBDebugPopMenu.h"
#import "XXBDebugMenuTitleView.h"
#import "XXBDebugUtilityConfig.h"
#import "XXBDebugUtility.h"

@interface XXBDebugConsole()<XXBDebugPopMenuDelegate, XXBDebugMenuTitleViewDelegate, XXBDebugConsoleMainButtonDelegate>
{
    /** 调试主窗口 */
    XXBDebugMainWindow                              *_mainWindow;
    
    /** 调试主按钮(悬浮窗) */
    XXBDebugConsoleMainButton                       *_mainButton;
    
    /** 弹出菜单 */
    XXBDebugPopMenu                                 *_popMenu;
    
    /** 主按钮拖拽结束后是否恢复菜单 */
    BOOL                                            _bRecoverPopMenu;
    
    /** 当前菜单标题 */
    XXBDebugMenuTitleView                               *_menuTitleLabel;
    
    /** 当前菜单组锁定状态 */
    XXBDebugMenuTitleView                               *_menuLockedLabel;
    
    /** 备选功能列表 */
    NSMutableArray <XXBDebugUtilityBackupFunc *>    *_arBackupFunctions;
    
    /** 允许显示的备选功能 */
    NSMutableArray <NSString *>      *_arBackupFuncOnShow;
    
    /** 锁定的菜单id */
    NSMutableArray <NSString *>     *_arLockedMenuItems;
}
@end

@implementation XXBDebugConsole

static id _shareInstance = nil;
+ (id)allocWithZone:(struct _NSZone *)zone {
    if (_shareInstance == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _shareInstance = [super allocWithZone:zone];
        });
    }
    return _shareInstance;
}

+ (instancetype)share {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareInstance = [[self alloc] init];
    });
    return _shareInstance;
}

- (id)copyWithZone:(NSZone *)zone {
    return _shareInstance;
}

+ (void)showConsole:(BOOL)show {
    [[self share] showConsole:show];
}


- (instancetype)init {
    if (self = [super init]) {
        [self creatDefaultUI];
    }
    return self;
}

- (void)creatDefaultUI {
    _mainWindow = [[XXBDebugMainWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _mainWindow.windowLevel = UIWindowLevelAlert + 5;
    
    _popMenu = [[XXBDebugPopMenu alloc] init];
    _popMenu.delegate = self;
    _popMenu.superView = _mainWindow;
    
    _menuTitleLabel = [[XXBDebugMenuTitleView alloc] initWithFrame:CGRectZero];
    _menuTitleLabel.delegate = self;
    [_mainWindow addDebugComponent:_menuTitleLabel];
    
    _menuLockedLabel = [[XXBDebugMenuTitleView alloc] initWithFrame:CGRectZero];
    _menuLockedLabel.font = [UIFont systemFontOfSize:18];
    _menuLockedLabel.delegate = self;
    _menuLockedLabel.revertPosition = YES;
    [_mainWindow addDebugComponent:_menuLockedLabel];
    
    _arBackupFunctions = [[NSMutableArray alloc] init];
    
    NSArray *arBackupFuncOnShow = [XXBDebugUtilityConfig backupFunctionsOnShow];
    [self setAvailableBackupFuncIds:arBackupFuncOnShow];
    
    NSArray *arLockedItems = [XXBDebugUtilityConfig lockedMenuIds];
    if( arLockedItems.count > 0 ) {
        _arLockedMenuItems = [[NSMutableArray alloc] initWithArray:arLockedItems];
    } else {
        _arLockedMenuItems = [[NSMutableArray alloc] init];
    }
}

#pragma mark - properties

/** 主菜单 */
- (XXBDebugPopMenu *)mainMenu {
    return _popMenu;
}

/** 是否已经是渐隐模式 */
- (BOOL)isTransparent {
    return _mainButton.isTransparent;
}

/** 主窗口 */
- (UIWindow *)mainWindow {
    return _mainWindow;
}

/** 添加一个调试按钮 */
- (BOOL)addDebugButtonWithID:(NSString *)identifier parentButton:(NSString *)parentID title:(NSString *)title action:(void(^)(NSString *buttonID))onClickBlock {
    if( [self hasBackupFunctionWithID:identifier] ) {
        // 是一个备选功能
        if( ![self backupFuncAvailable:identifier] ) {
            return NO;
        }
    }
    
    if( ![_popMenu addMenuItemWithID:identifier parentItem:parentID title:title action:onClickBlock] ) {
        return NO;
    }
    
    if( [_arLockedMenuItems containsObject:identifier] ) {
        [_popMenu setButtonLock:YES forButtonWithID:identifier];
    }
    
    if( !parentID && ![identifier isEqualToString:XXBDEBUGUTILITY_BACKUPFUNC_MENU_ID] ) {
        [self bringMenuToBottom:XXBDEBUGUTILITY_BACKUPFUNC_MENU_ID];
    }
    return YES;
}

/** 移除指定id的按钮 */
- (void)removeButtonWithID:(NSString *)identifier {
    [_popMenu removeMenuItemWithID:identifier];
}

/** 设置测试按钮的选中状态 */
- (void)checkButton:(BOOL)checked withButtonID:(NSString *)identifier {
    [_popMenu checkMenuItemWithID:identifier check:checked];
}

/** 将指定id的按钮移动到同组按钮的顶部 */
- (void)bringMenuToTop:(NSString *)identifier {
    [_popMenu bringMenuToTop:identifier];
}

/** 将指定id的按钮移动到同组按钮的底部 */
- (void)bringMenuToBottom:(NSString *)identifier {
    [_popMenu bringMenuToBottom:identifier];
}

/** 取消所有子按钮的选中状态 */
- (void)uncheckSubButtonWithID:(NSString *)identifier {
    [_popMenu uncheckMenuItemWithParentID:identifier];
}

/** 设置按钮文本 */
- (void)setButtonText:(NSString *)text forButtonWithID:(NSString *)identifier {
    [_popMenu setMenuItemText:text forItemWithID:identifier];
}

/** 锁定当前菜单组(点选后不收起) */
- (void)lockCurrentButtons:(BOOL)locked {
    [_popMenu lockCurrentButtons:locked];
}

/** 锁定指定菜单(点选子菜单后不收起) */
- (void)setButtonLock:(BOOL)locked forButtonWithID:(NSString *)identifier {
    [_popMenu setButtonLock:locked forButtonWithID:identifier];
}

/** 是否有指定id的功能按钮 */
- (BOOL)hasFunctionWithID:(NSString *)identifier {
    return [_popMenu hasFunctionWithID:identifier];
}

/** 指定的备选测试项是否启用 */
- (BOOL)backupFuncAvailable:(NSString *)identifier {
    if( !identifier.length ) {
        return NO;
    }
    
    for( NSString *strId in _arBackupFuncOnShow ) {
        if( [identifier isEqualToString:strId] ) {
            return YES;
        }
    }
    return NO;
}

/** 是否存在指定的备选测试项 */
- (BOOL)hasBackupFunctionWithID:(NSString *)identifier {
    return [self backupFuncWithID:identifier] != nil;
}

/** 设置启用备选测试项 */
- (void)setAvailableBackupFuncIds:(NSArray <NSString *> *)funcIds {
    // 首先移除不再启用的项目
    for( XXBDebugUtilityBackupFunc *func in _arBackupFunctions ) {
        if( [funcIds containsObject:func.menuID] ) {
            continue;
        }
        [self removeButtonWithID:func.menuID];
    }
    NSArray *arCurrent = _arBackupFuncOnShow;
    if( funcIds.count ) {
        _arBackupFuncOnShow = [NSMutableArray arrayWithArray:funcIds];
    } else {
        _arBackupFuncOnShow = [[NSMutableArray alloc] init];
    }
    // 启用新的项目
    for( NSString *strId in _arBackupFuncOnShow ) {
        if( [arCurrent containsObject:strId] )
        {
            continue;
        }
        XXBDebugUtilityBackupFunc *func = [self backupFuncWithID:strId];
        if (func.openBlock) {
            func.openBlock();
        }
    }
    [XXBDebugUtilityConfig setBackupFunctions:_arBackupFuncOnShow];
}

/** 获取全部备选测试项信息 */
- (NSArray <XXBDebugUtilityBackupFunc *> *)backupFuncs {
    return _arBackupFunctions;
}

/** 增加一个备选测试项 */
- (BOOL)addBackupFunction:(NSString *)identifier comment:(NSString *)comment openBlock:(void (^)(void))openBlock {
    if( !identifier.length ) {
        return NO;
    }
    
    if( [self hasBackupFunctionWithID:identifier] ) {
        return NO;
    }
    XXBDebugUtilityBackupFunc *func = [[XXBDebugUtilityBackupFunc alloc] init];
    func.menuID = identifier;
    func.openBlock = openBlock;
    func.comment = comment;
    [_arBackupFunctions addObject:func];
    if( [self backupFuncAvailable:identifier] ) {
        if( ![self hasFunctionWithID:identifier] ) {
            if(func.openBlock) {
                func.openBlock();
            }
        }
    } else if( [self hasFunctionWithID:identifier] ) {
        [self removeButtonWithID:identifier];
    }
    [self createBackupFunctionMenuItem];
    return YES;
}

/** 弹出指定标识的菜单 */
- (void)popButtonWithID:(NSString *)identifier {
    [_popMenu popParentMenu:identifier fromPoint:_mainButton.center];
}

#pragma mark - self operations
/** 显示控制台 */
- (void)showConsole:(BOOL)show {
    if( show == _isOnshow ) {
        return;
    }
    _isOnshow = show;
    [_mainButton removeFromSuperview];
    _mainButton = nil;
    if( show ) {
        _mainWindow.hidden = NO;
        
        _mainButton = [[XXBDebugConsoleMainButton alloc] init];
        _mainButton.delegate = self;
        [_mainWindow addDebugComponent:_mainButton];
    } else {
        _mainWindow.hidden = YES;
        [_popMenu unpop];
    }
    [XXBDebugUtilityConfig setConsoleShow:show];
}

/** 刷新菜单组锁定状态 */
- (void)refreshMenuLockStatus {
    NSString *strTitle = @"🖖";
    if( _popMenu.isRootMenu ) {
        strTitle = @"🚫 - Disable";
    } else if( _popMenu.currentMenuLocked ) {
        strTitle = @"✊ - MenuLocked";
    }
    _menuLockedLabel.text = strTitle;
}

/** 获取指定id的备选功能信息 */
- (XXBDebugUtilityBackupFunc *)backupFuncWithID:(NSString *)identifier {
    if( !identifier.length ) {
        return nil;
    }
    for( XXBDebugUtilityBackupFunc *func in _arBackupFunctions ) {
        if( [func.menuID isEqualToString:identifier] ) {
            return func;
        }
    }
    return nil;
}

/** 创建备选功能配置菜单 */
- (void)createBackupFunctionMenuItem {
    if( _arBackupFunctions.count && ![self hasFunctionWithID:XXBDEBUGUTILITY_BACKUPFUNC_MENU_ID] ) {
        [_popMenu addMenuItemWithID:XXBDEBUGUTILITY_BACKUPFUNC_MENU_ID parentItem:nil title:@".｡o○ 更多" action:^(NSString *buttonID) {
            [XXBDebugUtility showBackupFuncView:YES];
        }];
        [_popMenu setMenuItemTextColor:[UIColor yellowColor] forItemWithID:XXBDEBUGUTILITY_BACKUPFUNC_MENU_ID];
    }
}


#pragma mark - console main button delegate
/** 主按钮按下 */
- (void)debugConsoleMainButtonDidClicked:(XXBDebugConsoleMainButton *)button {
    [_popMenu switchPopOfPoint:button.center];
}


/** 主按钮开始拖拽 */
- (void)debugConsoleMainButtonDidBeginDragging:(XXBDebugConsoleMainButton *)button {
    if( _popMenu.poped ) {
        _bRecoverPopMenu = YES;
        [_popMenu unpopForTemp];
    } else {
        _bRecoverPopMenu = NO;
    }
}

/** 主按钮停止拖拽 */
- (void)debugConsoleMainButtonDidEndDragging:(XXBDebugConsoleMainButton *)button {
    if( _bRecoverPopMenu )
    {
        [_popMenu recoverPopFromPoint:button.center];
    }
    _bRecoverPopMenu = NO;
}


#pragma mark - XXBDebugPopMenuDelegate
- (void)debugPopMenuWillShow:(XXBDebugPopMenu *)menu {
    _mainButton.pausetimer = YES;
    _menuTitleLabel.text = menu.currentMenuTitle;
    [_mainButton showBkAnimate];
    [_menuTitleLabel showFromPoint:_mainButton.center];
    [self refreshMenuLockStatus];
    [_menuLockedLabel showFromPoint:_mainButton.center];
}

- (void)debugPopMenuWillDisappear:(XXBDebugPopMenu *)menu {
    _mainButton.pausetimer = NO;
    [_menuTitleLabel hide];
    [_menuLockedLabel hide];
}

- (void)debugPopMenuDidLockMenu:(NSString *)parentID locked:(BOOL)lock {
    if( !parentID.length ) {
        return;
    }
    if( lock ) {
        if( [_arLockedMenuItems containsObject:parentID] ) {
            return;
        }
        [_arLockedMenuItems addObject:parentID];
        [XXBDebugUtilityConfig setMenuLocked:lock identifier:parentID];
    } else {
        if( ![_arLockedMenuItems containsObject:parentID] ) {
            return;
        }
        [_arLockedMenuItems removeObject:parentID];
        [XXBDebugUtilityConfig setMenuLocked:lock identifier:parentID];
    }
}

#pragma mark - SNDebugMenuTitleDelegate
/** 标题按下 */
- (void)debugMenuTitleDidClick:(XXBDebugMenuTitleView *)title {
    if( title == _menuTitleLabel ) {
        [_popMenu returnToUplevel];
    } else if( title == _menuLockedLabel ) {
        if( _popMenu.isRootMenu ) {
            // 根菜单, 关闭控制台
            [self showConsole:NO];
        }
        [_popMenu switchCurrentMenuLockStatus];
        [self refreshMenuLockStatus];
    }
}

@end
