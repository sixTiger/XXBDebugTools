//
//  XXBDebugUtilityConfig.m
//  XXBDebugToolsDemo
//
//  Created by xiaobing5 on 2018/4/26.
//  Copyright © 2018年 xiaobing5. All rights reserved.
//

#import "XXBDebugUtilityConfig.h"

// 缓存key
#define XXBDEBUGUTILITY_CONFIG_KEY_CONSOLE_SHOW      @"showConsole"
#define XXBDEBUGUTILITY_CONFIG_KEY_BACKUPFUNCTIONS   @"backupFunc"
#define XXBDEBUGUTILITY_CONFIG_KEY_LOCKEDMENU        @"lockedMenus"
#define XXBDEBUGUTILITY_CONFIG_KEY_CONSOLEPOSITION   @"consolePosition"
#define XXBDEBUGUTILITY_CONFIG_KEY_CUSTOM            @"custom"

@interface XXBDebugUtilityConfig()
/** 缓存根字典 */
+ (NSMutableDictionary *)rootDictforSave:(BOOL)forSave;

/** 保存缓存 */
+ (void)saveRootDict:(NSDictionary *)rootDict;
@end

@implementation XXBDebugUtilityConfig
/** 缓存文件夹 */
+ (NSString *)cacheDir {
    return [NSString stringWithFormat:@"%@/Documents/Debug", NSHomeDirectory()];
}

/** 缓存文件名 */
+ (NSString *)cacheFile {
    return [[self cacheDir] stringByAppendingPathComponent:@"utilityConfig.plist"];
}

/** 设置控制台是否显示 */
+ (void)setConsoleShow:(BOOL)show {
    NSMutableDictionary *rootDict = [self rootDictforSave:YES];
    NSNumber *num = [rootDict objectForKey:XXBDEBUGUTILITY_CONFIG_KEY_CONSOLE_SHOW];
    if( ![num isKindOfClass:[NSNumber class]] ) {
        num = [NSNumber numberWithBool:NO];
    }
    if( [num boolValue] == show ) {
        return;
    }
    num = [NSNumber numberWithBool:show];
    [rootDict setObject:num forKey:XXBDEBUGUTILITY_CONFIG_KEY_CONSOLE_SHOW];
    [self saveRootDict:rootDict];
}

/** 获取控制台是否显示 */
+ (BOOL)consoleShow {
    NSNumber *num = [[self rootDictforSave:NO] objectForKey:XXBDEBUGUTILITY_CONFIG_KEY_CONSOLE_SHOW];
    if( [num isKindOfClass:[NSNumber class]] ) {
        return num.boolValue;
    }
    return NO;
}


/** 添加备选菜单缓存 */
+ (void)addBackupFunctionWithMenuID:(NSString *)menuID available:(BOOL)available {
    if( !menuID.length )
    {
        return;
    }
    NSMutableDictionary *rootDict = [self rootDictforSave:YES];
    NSMutableArray *arIds = [rootDict objectForKey:XXBDEBUGUTILITY_CONFIG_KEY_BACKUPFUNCTIONS];
    if( !arIds ) {
        arIds = [[NSMutableArray alloc] init];
        [rootDict setObject:arIds forKey:XXBDEBUGUTILITY_CONFIG_KEY_BACKUPFUNCTIONS];
    }
    if( !available ) {
        if( ![arIds containsObject:menuID] )
        {
            return;
        }
        [arIds removeObject:menuID];
    } else {
        if( [arIds containsObject:menuID] ){
            return;
        }
        [arIds addObject:menuID];
    }
    [self saveRootDict:rootDict];
}

/** 设置启用的备选菜单id */
+ (void)setBackupFunctions:(NSArray <NSString *> *)menuIDs {
    NSMutableDictionary *rootDict = [self rootDictforSave:YES];
    [rootDict setValue:menuIDs forKey:XXBDEBUGUTILITY_CONFIG_KEY_BACKUPFUNCTIONS];
    [self saveRootDict:rootDict];
}


/** 获取显示的备选菜单 */
+ (NSArray <NSString *> *)backupFunctionsOnShow {
    return [[self rootDictforSave:NO] objectForKey:XXBDEBUGUTILITY_CONFIG_KEY_BACKUPFUNCTIONS];
}

/** 设置菜单组锁定状态 */
+ (void)setMenuLocked:(BOOL)locked identifier:(NSString *)identifier {
    if( !identifier.length ) {
        return;
    }
    NSMutableDictionary *rootDict = [self rootDictforSave:YES];
    NSMutableArray *arIds = [rootDict objectForKey:XXBDEBUGUTILITY_CONFIG_KEY_LOCKEDMENU];
    if( !arIds ) {
        arIds = [[NSMutableArray alloc] init];
        [rootDict setObject:arIds forKey:XXBDEBUGUTILITY_CONFIG_KEY_LOCKEDMENU];
    }
    if( !locked ) {
        if( ![arIds containsObject:identifier] ) {
            return;
        }
        [arIds removeObject:identifier];
    } else {
        if( [arIds containsObject:identifier] ) {
            return;
        }
        [arIds addObject:identifier];
    }
    [self saveRootDict:rootDict];
}

/** 获取所有锁定的菜单id */
+ (NSArray <NSString *> *)lockedMenuIds {
    return [[self rootDictforSave:NO] objectForKey:XXBDEBUGUTILITY_CONFIG_KEY_LOCKEDMENU];
}

/** 设置按钮位置 */
+ (void)setConsolePosition:(CGPoint)pt {
    NSMutableDictionary *rootDict = [self rootDictforSave:YES];
    NSString *strValue = [NSString stringWithFormat:@"%.0f,%.0f", pt.x, pt.y];
    [rootDict setObject:strValue forKey:XXBDEBUGUTILITY_CONFIG_KEY_CONSOLEPOSITION];
    [self saveRootDict:rootDict];
}

/** 获取按钮位置 */
+ (CGPoint)consolePosition {
    NSString *strValue = [[self rootDictforSave:NO] objectForKey:XXBDEBUGUTILITY_CONFIG_KEY_CONSOLEPOSITION];
    do {
        if( ![strValue isKindOfClass:[NSString class]] ) {
            break;
        }
        NSArray *arValue = [strValue componentsSeparatedByString:@","];
        if( 2 != arValue.count ) {
            break;
        }
        NSString *str1 = [arValue firstObject];
        NSString *str2 = [arValue lastObject];
        CGPoint pt;
        pt.x = str1.floatValue;
        pt.y = str2.floatValue;
        return pt;
    }while(0);
    return CGPointZero;
}

/** 保存一个String */
+ (void)saveString:(NSString *)string forKey:(NSString *)key {
    if( !key.length ) {
        return;
    }
    NSMutableDictionary *rootDict = [self rootDictforSave:YES];
    NSMutableDictionary *customDict = [rootDict objectForKey:XXBDEBUGUTILITY_CONFIG_KEY_CUSTOM];
    if( !customDict ) {
        customDict = [[NSMutableDictionary alloc] init];
        [rootDict setObject:customDict forKey:XXBDEBUGUTILITY_CONFIG_KEY_CUSTOM];
    }
    [customDict setValue:string forKey:key];
    [self saveRootDict:rootDict];
}

/** 获取保存的string */
+ (NSString *)stringForKey:(NSString *)key {
    if( !key.length ) {
        return nil;
    }
    NSDictionary *rootDict = [self rootDictforSave:NO];
    NSDictionary *customDict = [rootDict objectForKey:XXBDEBUGUTILITY_CONFIG_KEY_CUSTOM];
    return [customDict objectForKey:key];
}


#pragma mark - self operations
/** 缓存根字典 */
+ (NSMutableDictionary *)rootDictforSave:(BOOL)forSave; {
    if( forSave ) {
        NSString *strPath = [self cacheDir];
        [[NSFileManager defaultManager] createDirectoryAtPath:strPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *strFile = [self cacheFile];
    NSMutableDictionary *rootDict = [NSMutableDictionary dictionaryWithContentsOfFile:strFile];
    if( !rootDict || ![rootDict isKindOfClass:[NSMutableDictionary class]] ) {
        if( forSave ) {
            rootDict = [[NSMutableDictionary alloc] init];
        }
    }
    return rootDict;
}

/** 保存缓存 */
+ (void)saveRootDict:(NSDictionary *)rootDict {
    [rootDict writeToFile:[self cacheFile] atomically:YES];
}

@end
