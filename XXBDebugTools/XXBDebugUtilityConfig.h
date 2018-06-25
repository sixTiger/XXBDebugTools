//
//  XXBDebugUtilityConfig.h
//  XXBDebugToolsDemo
//
//  Created by xiaobing5 on 2018/4/26.
//  Copyright © 2018年 xiaobing5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface XXBDebugUtilityConfig : NSObject
/** 缓存文件夹 */
+ (NSString *)cacheDir;

/** 缓存文件名 */
+ (NSString *)cacheFile;

/** 设置控制台是否显示 */
+ (void)setConsoleShow:(BOOL)show;

/** 获取控制台是否显示 */
+ (BOOL)consoleShow;

/** 添加备选菜单缓存 */
+ (void)addBackupFunctionWithMenuID:(NSString *)menuID available:(BOOL)available;

/** 设置启用的备选菜单id */
+ (void)setBackupFunctions:(NSArray <NSString *> *)menuIDs;

/** 获取显示的备选菜单 */
+ (NSArray <NSString *> *)backupFunctionsOnShow;

/** 设置菜单组锁定状态 */
+ (void)setMenuLocked:(BOOL)locked identifier:(NSString *)identifier;

/** 获取所有锁定的菜单id */
+ (NSArray <NSString *> *)lockedMenuIds;

/** 设置按钮位置 */
+ (void)setConsolePosition:(CGPoint)pt;

/** 获取按钮位置 */
+ (CGPoint)consolePosition;

/** 保存一个String */
+ (void)saveString:(NSString *)string forKey:(NSString *)key;

/** 获取保存的string */
+ (NSString *)stringForKey:(NSString *)key;
@end
