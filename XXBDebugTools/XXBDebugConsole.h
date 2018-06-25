//
//  XXBDebugConsole.h
//  XXBDebugToolsDemo
//
//  Created by xiaobing5 on 2018/4/25.
//  Copyright © 2018年 xiaobing5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XXBDebugUtilityBackupFunc.h"
#import "XXBDebugPopMenu.h"

@interface XXBDebugConsole : NSObject

/** 主窗口 */
@property (nonatomic, readonly) UIWindow            *mainWindow;

/**
 主菜单
 */
@property (nonatomic, readonly) XXBDebugPopMenu     *mainMenu;

/** 是否在显示 */
@property (nonatomic, readonly) BOOL                isOnshow;

/**
 是否已经是渐隐模式
 */
@property (nonatomic, readonly) BOOL                isTransparent;

+ (instancetype)share;

/**
 显示控制台
 
 @param show 显示为YES
 */
+ (void)showConsole:(BOOL)show;


/**
 显示控制台
 
 @param show 显示为YES
 */
- (void)showConsole:(BOOL)show;

/**
 添加一个调试按钮
 
 @param identifier 按钮id
 @param parentID 父按钮id
 @param onClickBlock 按钮回调
 @discussion 若parentID为nil, 则添加为第一级按钮
 @return 创建成功返回YES.
 */
- (BOOL)addDebugButtonWithID:(NSString *)identifier parentButton:(NSString *)parentID title:(NSString *)title action:(void(^)(NSString *buttonID))onClickBlock;


/** 移除指定id的按钮 */
- (void)removeButtonWithID:(NSString *)identifier;

/** 设置测试按钮的选中状态 */
- (void)checkButton:(BOOL)checked withButtonID:(NSString *)identifier;

/** 将指定id的按钮移动到同组按钮的顶部 */
- (void)bringMenuToTop:(NSString *)identifier;

/** 将指定id的按钮移动到同组按钮的底部 */
- (void)bringMenuToBottom:(NSString *)identifier;

/** 取消所有子按钮的选中状态 */
- (void)uncheckSubButtonWithID:(NSString *)identifier;

/** 设置按钮文本 */
- (void)setButtonText:(NSString *)text forButtonWithID:(NSString *)identifier;

/** 锁定当前菜单组(点选后不收起) */
- (void)lockCurrentButtons:(BOOL)locked;

/** 锁定指定菜单(点选子菜单后不收起) */
- (void)setButtonLock:(BOOL)locked forButtonWithID:(NSString *)identifier;

/** 是否有指定id的功能按钮 */
- (BOOL)hasFunctionWithID:(NSString *)identifier;

/** 指定的备选测试项是否启用 */
- (BOOL)backupFuncAvailable:(NSString *)identifier;

/** 是否存在指定的备选测试项 */
- (BOOL)hasBackupFunctionWithID:(NSString *)identifier;

/** 设置启用备选测试项 */
- (void)setAvailableBackupFuncIds:(NSArray <NSString *> *)funcIds;

/** 获取全部备选测试项信息 */
- (NSArray <XXBDebugUtilityBackupFunc *> *)backupFuncs;

/** 增加一个备选测试项 */
- (BOOL)addBackupFunction:(NSString *)identifier comment:(NSString *)comment openBlock:(void (^)(void))openBlock;

/** 弹出指定标识的菜单 */
- (void)popButtonWithID:(NSString *)identifier;

@end
