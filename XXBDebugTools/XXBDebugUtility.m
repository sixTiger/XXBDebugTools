//
//  XXBDebugUtility.m
//  XXBDebugToolsDemo
//
//  Created by xiaobing5 on 2018/4/26.
//  Copyright © 2018年 xiaobing5. All rights reserved.
//

#import "XXBDebugUtility.h"
#import "XXBDebugUtilityConfig.h"
#import "XXBDebugConsole.h"
#import "XXBDebugBackupFuncSelView.h"
#import "XXBDebugUtilityBackupFunc.h"

@implementation XXBDebugUtility
+ (void)load {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if( [XXBDebugUtilityConfig consoleShow] ) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self showConsole:YES];
            });
        }
    });
}

#pragma mark - methods
/** 添加一个调试按钮 */
+ (BOOL)addDebugButtonWithID:(NSString *)identifier parentButton:(NSString *)parentID title:(NSString *)title action:(void(^)(NSString *buttonID))onClickBlock {
    return [[XXBDebugConsole share] addDebugButtonWithID:identifier parentButton:parentID title:title action:onClickBlock];
}

/** 移除指定id的按钮 */
+ (void)removeButtonWithID:(NSString *)identifier {
    return [[XXBDebugConsole share] removeButtonWithID:identifier];
}

/** 设置测试按钮的选中状态 */
+ (void)checkButton:(BOOL)checked withButtonID:(NSString *)identifier {
    [[XXBDebugConsole share] checkButton:checked withButtonID:identifier];
}

/** 将指定id的按钮移动到同组按钮的顶部 */
+ (void)bringMenuToTop:(NSString *)identifier {
    [[XXBDebugConsole share] bringMenuToTop:identifier];
}

/** 将指定id的按钮移动到同组按钮的底部 */
+ (void)bringMenuToBottom:(NSString *)identifier {
    [[XXBDebugConsole share] bringMenuToBottom:identifier];
}


/** 取消所有子按钮的选中状态 */
+ (void)uncheckSubButtonWithID:(NSString *)identifier {
    [[XXBDebugConsole share] uncheckSubButtonWithID:identifier];
}

/** 设置按钮文本 */
+ (void)setButtonText:(NSString *)text forButtonWithID:(NSString *)identifier {
    [[XXBDebugConsole share] setButtonText:text forButtonWithID:identifier];
}

/** 锁定当前菜单组(点选后不收起) */
+ (void)lockCurrentButtons:(BOOL)locked {
    [[XXBDebugConsole share] lockCurrentButtons:locked];
}

/** 锁定指定菜单(点选子菜单后不收起) */
+ (void)setButtonLock:(BOOL)locked forButtonWithID:(NSString *)identifier {
    [[XXBDebugConsole share] setButtonLock:locked forButtonWithID:identifier];
}

/** 显示编辑视图 */
+ (void)showInputViewWithString:(NSString *)str title:(NSString *)title finishBlock:(void(^)(NSString *final))block {
//    [SNDebugUtilityInputView showWithString:str title:title finishBlock:block];
}

/** 显示备选功能视图 */
+ (void)showBackupFuncView:(BOOL)show {
    [XXBDebugBackupFuncSelView show:show];
}


/** 是否有指定id的功能按钮 */
+ (BOOL)hasFunctionWithID:(NSString *)identifier {
    return [[XXBDebugConsole share] hasFunctionWithID:identifier];
}

/** 注册一个备选测试项(只能在根菜单) */
+ (BOOL)registerBackupFunction:(NSString *)identifier comment:(NSString *)comment openBlock:(void (^)(void))openBlock {
    if (openBlock) {
        return [[XXBDebugConsole share] addBackupFunction:identifier comment:comment openBlock:openBlock];
    } else {
        return NO;
    }

}

/** 设置启用备选测试项 */
+ (void)setAvailableBackupFuncIds:(NSArray <NSString *> *)funcIds
{
    [[XXBDebugConsole share] setAvailableBackupFuncIds:funcIds];
}

/** 获取全部备选测试项信息 */
+ (NSArray <XXBDebugUtilityBackupFunc *> *)backupFuncs {
    return [[XXBDebugConsole share] backupFuncs];
}

/** 指定的备选测试项是否启用 */
+ (BOOL)backupFuncAvailable:(NSString *)identifier {
    return [[XXBDebugConsole share] backupFuncAvailable:identifier];
}

/** 显示控制台 */
+ (void)showConsole:(BOOL)show {
    [[XXBDebugConsole share] showConsole:show];
}


/** 控制台是否正在显示 */
+ (BOOL)isConsoleOnshow {
    return [XXBDebugConsole share].isOnshow;
}

/** 弹出指定标识的菜单 */
+ (void)popButtonWithID:(NSString *)identifier {
    [[XXBDebugConsole share] popButtonWithID:identifier];
}
@end
