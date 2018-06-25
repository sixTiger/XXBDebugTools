//
//  XXBDebugPopMenu.m
//  XXBDebugToolsDemo
//
//  Created by xiaobing5 on 2018/4/26.
//  Copyright © 2018年 xiaobing5. All rights reserved.
//

#import "XXBDebugPopMenu.h"
#import "XXBDebugMenuItemView.h"
#import "XXBDebugMainWindow.h"
#import "XXBDebugConsoleMainButton.h"

@interface XXBDebugPopMenu()<XXBDebugMenuItemViewDelegate>
{
    /** 菜单项数组 */
    NSMutableArray<XXBDebugMenuItemView*>       *_arItems;
    
    /** 是否已经弹出 */
    BOOL                                    _bPoped;
    
    /** 子菜单项最小宽度 */
    CGFloat                                 _fMinItemWidth;
}

/** 是否正在弹出菜单项 */
@property (nonatomic, assign) BOOL                          popingMenuItems;

/** 弹出菜单的中心点 */
@property (nonatomic, assign) CGPoint                       ptMenuCenter;

/** 当前弹出的菜单列表 */
@property (nonatomic, weak) NSArray <XXBDebugMenuItemView*>     *currentPopedMenus;

/** 当前弹出的父菜单 */
@property (nonatomic, weak) XXBDebugMenuItemView                *currentParentItem;

/** 指定id的菜单项 */
- (XXBDebugMenuItemView *)menuItemWithID:(NSString *)identifier;

/** 弹出当前的菜单 */
- (void)popCurrentMenusWithCompletion:(void(^)(void))completion;

/** 收起当前的菜单 */
- (void)unpopCurrentMenusWithCompletion:(void(^)(void))completion;

/** 锁定指定菜单组 */
- (void)lockParentMenu:(XXBDebugMenuItemView *)parentItem locked:(BOOL)locked;

@end

@implementation XXBDebugPopMenu
- (instancetype)init {
    if( self = [super init] ) {
        _arItems = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - properties
- (void)setSuperView:(XXBDebugMainWindow *)superView {
    _superView = superView;
    _fMinItemWidth = _superView.frame.size.width / 4;
}

- (BOOL)poped {
    return _bPoped;
}

/** 当前菜单标题 */
- (NSString *)currentMenuTitle {
    if( !_currentParentItem ) {
        return @"功能选择";
    }
    return _currentParentItem.title;
}

/** 当前菜单组的锁定状态 */
- (BOOL)currentMenuLocked {
    if( !_currentParentItem ) {
        return NO;
    }
    return _currentParentItem.locked;
}

/** 当前菜单是否是根菜单 */
- (BOOL)isRootMenu {
    return _currentParentItem == nil;
}

#pragma mark - methods
/** 弹出菜单 */
- (void)popFromPoint:(CGPoint)point {
    if( _bPoped ) {
        [self unpop];
        return;
    }
    _ptMenuCenter = point;
    self.currentParentItem = nil;
    self.currentPopedMenus = _arItems;
    [self popCurrentMenusWithCompletion:nil];
}

/** 收起菜单 */
- (void)unpop {
    if( !_bPoped ) {
        return;
    }
    [self unpopCurrentMenusWithCompletion:nil];
    _currentPopedMenus = nil;
    _currentParentItem = nil;
}

/** 若当前菜单组未锁定则收起 */
- (void)unpopIfUnlocked {
    if( _currentParentItem.locked ) {
        return;
    }
    [self unpop];
}

/** 暂时收起菜单, 下次弹出时使用当前菜单级别 */
- (void)unpopForTemp {
    if( !_bPoped ) {
        return;
    }
    [self unpopCurrentMenusWithCompletion:nil];
}

/** 恢复菜单 */
- (void)recoverPopFromPoint:(CGPoint)point {
    if( _bPoped ) {
        [self unpop];
        return;
    }
    _ptMenuCenter = point;
    if( !_currentPopedMenus ) {
        self.currentPopedMenus = _arItems;
        self.currentParentItem = nil;
    }
    [self popCurrentMenusWithCompletion:nil];
}

/** 返回到上一级菜单 */
- (void)returnToUplevel {
    if( !_currentParentItem ) {
        [self unpop];
        return;
    }
    XXBDebugMenuItemView *parentItem = _currentParentItem.parentItem;
    [self unpopCurrentMenusWithCompletion:^{
        if( parentItem ) {
            [self menuItemDidClicked:parentItem];
        } else {
            [self popFromPoint:self.ptMenuCenter];
        }
    }];
}

/** 切换当前菜单组的锁定状态 */
- (void)switchCurrentMenuLockStatus {
    if( !_currentParentItem ) {
        return;
    }
    [self lockParentMenu:_currentParentItem locked:!_currentParentItem.locked];
}

/** 切换弹出状态 */
- (void)switchPopOfPoint:(CGPoint)point {
    _bPoped ? [self unpop] : [self popFromPoint:point];
}

/** 添加一个菜单项 */
- (BOOL)addMenuItemWithID:(NSString *)identifier parentItem:(NSString *)parentID title:(NSString *)title action:(void(^)(NSString *buttonID))onClickBlock {
    XXBDebugMenuItemView *item = [self menuItemWithID:identifier];
    if( item ) {
        // 重复id的菜单项, 替换title和action
        item.title = title;
        item.clickBlock = onClickBlock;
        return NO;
    }
    item = [[XXBDebugMenuItemView alloc] init];
    item.minWidth = _fMinItemWidth;
    if( [_superView isKindOfClass:[XXBDebugMainWindow class]] ) {
        [_superView addDebugComponent:item];
    } else {
        [_superView addSubview:item];
    }
    item.title = title;
    item.clickBlock = onClickBlock;
    item.delegate = self;
    item.identifier = identifier;
    if( parentID ) {
        XXBDebugMenuItemView *parentItem = [self menuItemWithID:parentID];
        if( !parentItem ) {
            return NO;
        }
        [parentItem addSubitem:item];
    } else {
        [_arItems addObject:item];
    }
    return YES;
}

/** 移除一个菜单项 */
- (void)removeMenuItemWithID:(NSString *)identifier {
    NSArray * m_arItems = [_arItems copy];
    for( XXBDebugMenuItemView *item in m_arItems ) {
        if( [item.identifier isEqualToString:identifier] ) {
            [self unpop];
            [_arItems removeObject:item];
            return;
        }
        if( [item removeSubitemWithID:identifier] ) {
            [self unpop];
            return;
        }
    }
}

/** 设置菜单项选中态 */
- (void)checkMenuItemWithID:(NSString *)identifier check:(BOOL)check; {
    XXBDebugMenuItemView *item = [self menuItemWithID:identifier];
    if( !item ) {
        return;
    }
    item.checked = check;
}

/** 将指定id的按钮移动到同组按钮的顶部 */
- (BOOL)bringMenuToTop:(NSString *)identifier {
    XXBDebugMenuItemView *item = [self menuItemWithID:identifier];
    if( !item ) {
        return NO;
    }
    NSMutableArray *subItems = nil;
    if( !item.parentItem ) {
        subItems = _arItems;
    } else {
        subItems = item.parentItem.subItems;
    }
    [subItems removeObject:item];
    [subItems insertObject:item atIndex:0];
    return YES;
}

/** 将指定id的按钮移动到同组按钮的底部 */
- (BOOL)bringMenuToBottom:(NSString *)identifier {
    XXBDebugMenuItemView *item = [self menuItemWithID:identifier];
    if( !item ) {
        return NO;
    }
    NSMutableArray *subItems = nil;
    if( !item.parentItem ) {
        subItems = _arItems;
    } else {
        subItems = item.parentItem.subItems;
    }
    [subItems removeObject:item];
    [subItems addObject:item];
    return YES;
}

/** 设置菜单项文本 */
- (void)setMenuItemText:(NSString *)text forItemWithID:(NSString *)identifier {
    XXBDebugMenuItemView *item = [self menuItemWithID:identifier];
    if( !item ) {
        return;
    }
    item.title = text;
}

/** 取消选中指定父级菜单的所有子菜单 */
- (void)uncheckMenuItemWithParentID:(NSString *)parentIdentifier; {
    XXBDebugMenuItemView *item = [self menuItemWithID:parentIdentifier];
    if( !item ) {
        return;
    }
    [item uncheckAllSubitems];
}

/** 锁定当前菜单组(点选后不收起 */
- (void)lockCurrentButtons:(BOOL)locked {
    [self lockParentMenu:_currentParentItem locked:locked];
}

/** 锁定指定菜单(点选子菜单后不收起) */
- (void)setButtonLock:(BOOL)locked forButtonWithID:(NSString *)identifier {
    XXBDebugMenuItemView *item = [self menuItemWithID:identifier];
    [self lockParentMenu:item locked:locked];
}

/** 是否有指定id的功能按钮 */
- (BOOL)hasFunctionWithID:(NSString *)identifier {
    return [self menuItemWithID:identifier] != nil;
}

/** 设置菜单标题颜色 */
- (void)setMenuItemTextColor:(UIColor *)color forItemWithID:(NSString *)identifier {
    XXBDebugMenuItemView *item = [self menuItemWithID:identifier];
    item.titleColor = color;
}

/** 设置菜单背景色 */
- (void)setMenuItemBkgndColor:(UIColor *)color forItemWithID:(NSString *)identifier {
    XXBDebugMenuItemView *item = [self menuItemWithID:identifier];
    item.bkgndColor = color;
}

/** 弹出指定菜单项 */
- (void)popParentMenu:(NSString *)identifier fromPoint:(CGPoint)point {
    XXBDebugMenuItemView *item = [self menuItemWithID:identifier];
    if( !item ) {
        return;
    }
    NSArray <XXBDebugMenuItemView *> *subitems = item.subItems;
    if( !subitems.count ) {
        return;
    }
    _ptMenuCenter = point;
    if( _currentPopedMenus ) {
        [self unpopCurrentMenusWithCompletion:^{
            self.currentPopedMenus = subitems;
            self.currentParentItem = item;
            [self popCurrentMenusWithCompletion:nil];
        }];
    } else {
        self.currentPopedMenus = subitems;
        self.currentParentItem = item;
        [self popCurrentMenusWithCompletion:nil];
    }
}


#pragma mark - self operations
/** 指定id的菜单项 */
- (XXBDebugMenuItemView *)menuItemWithID:(NSString *)identifier {
    for( XXBDebugMenuItemView *item in _arItems ) {
        if( [item.identifier isEqualToString:identifier] ) {
            return item;
        }
        XXBDebugMenuItemView *subitem = [item subitemWithID:identifier];
        if( subitem ) {
            return subitem;
        }
    }
    return nil;
}


#pragma mark - SNDebugMenuItemDelegate
- (void)menuItemDidClicked:(XXBDebugMenuItemView *)item {
    NSArray <XXBDebugMenuItemView *> *subitems = item.subItems;
    if( subitems.count ) {
        [self unpopCurrentMenusWithCompletion:^{
            self.currentPopedMenus = subitems;
            self.currentParentItem = item;
            [self popCurrentMenusWithCompletion:nil];
        }];
    } else {
        [self unpopIfUnlocked];
    }
}

/** 弹出当前的菜单 */
- (void)popCurrentMenusWithCompletion:(void(^)(void))completion {
    if( !_currentPopedMenus.count ) {
        if( completion ) {
            completion();
        }
        return;
    }
    _bPoped = YES;
    if( [_delegate respondsToSelector:@selector(debugPopMenuWillShow:)] ) {
        [_delegate debugPopMenuWillShow:self];
    }
    
    self.popingMenuItems = YES;
    CGFloat fStep = 0.03;   // 菜单弹出时间间隔
    CGFloat fDelay = 0;
    __weak typeof(self) wSelf = self;
    
    // 计算全部菜单项整体高度
    CGFloat fTotalHeight = 0;
    for( XXBDebugMenuItemView *item in _currentPopedMenus ) {
        fTotalHeight += item.bounds.size.height;
    }
    CGFloat fBlank = XXBDEBUGMENUITEM_BKIMAGE_EDGE + 1;        // 菜单项间隔
    if( fTotalHeight + fBlank * (_currentPopedMenus.count - 1) > _superView.bounds.size.height - 20 ) {
        fBlank = (_superView.bounds.size.height - fTotalHeight - 20) / (_currentPopedMenus.count - 1);
    }
    CGPoint pos;    // 菜单项弹出起始位置
    fTotalHeight += fBlank * (_currentPopedMenus.count - 1);
    BOOL bLeftAlign = YES;      // 是否左对齐
    CGFloat fMaxWidth = 0;
    if( _ptMenuCenter.x < _superView.bounds.size.width / 2 ) {
        // 向右侧弹出
        pos.x = XXBDEBUGCONSOLEMAINBUTTON_WIDTH * 1.1 + _ptMenuCenter.x;
        fMaxWidth = _superView.bounds.size.width - pos.x - 10;
    } else {
        // 向左侧弹出
        bLeftAlign = NO;
        pos.x = _ptMenuCenter.x - XXBDEBUGCONSOLEMAINBUTTON_WIDTH * 1.1;
        fMaxWidth = pos.x - 10;
    }
    pos.y = _ptMenuCenter.y - fTotalHeight / 2;
    if( pos.y + fTotalHeight > _superView.bounds.size.height ) {
        pos.y = _superView.bounds.size.height - fTotalHeight;
    }
    if( pos.y < 20 ) {
        pos.y = 20;
    }
    for( XXBDebugMenuItemView *item in _currentPopedMenus ) {
        item.maxWidth = fMaxWidth;
        CGPoint itemPos = pos;
        if( bLeftAlign ) {
            itemPos.x += item.bounds.size.width / 2;
        } else {
            itemPos.x -= item.bounds.size.width / 2;
        }
        itemPos.y += item.bounds.size.height / 2;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(fDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if( !wSelf.popingMenuItems ) {
                return;
            }
            [item openMenuItemFromPoint:wSelf.ptMenuCenter toPoint:itemPos];
        });
        fDelay += fStep;
        pos.y += item.bounds.size.height + fBlank;
    }
}

/** 收起当前的菜单 */
- (void)unpopCurrentMenusWithCompletion:(void(^)(void))completion {
    if( !_currentPopedMenus ) {
        if( completion ) {
            completion();
        }
        return;
    }
    _bPoped = NO;
    if( [_delegate respondsToSelector:@selector(debugPopMenuWillDisappear:)] ) {
        [_delegate debugPopMenuWillDisappear:self];
    }
    self.popingMenuItems = NO;
    for( XXBDebugMenuItemView *item in _currentPopedMenus ) {
        [item closeMenuItem];
    }
    if( completion ) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(XXBDEBUGMENUITEM_ANIMATION_TIME * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            completion();
        });
    }
}

/** 锁定指定菜单组 */
- (void)lockParentMenu:(XXBDebugMenuItemView *)parentItem locked:(BOOL)locked {
    if( !parentItem ) {
        return;
    }
    if( locked == parentItem.locked ) {
        return;
    }
    parentItem.locked = locked;
    if( [_delegate respondsToSelector:@selector(debugPopMenuDidLockMenu:locked:)] ) {
        [_delegate debugPopMenuDidLockMenu:parentItem.identifier locked:locked];
    }
}
@end
