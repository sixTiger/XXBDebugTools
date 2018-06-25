//
//  XXBDebugUtilityBackupFunc.h
//  XXBDebugToolsDemo
//
//  Created by xiaobing5 on 2018/4/26.
//  Copyright © 2018年 xiaobing5. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XXBDebugUtilityBackupFunc : NSObject

/** 菜单id */
@property (nonatomic, copy) NSString    *menuID;

/** 注释 */
@property (nonatomic, copy) NSString    *comment;

/** 开启菜单的block */
@property (nonatomic, copy) void (^openBlock)(void);
@end
