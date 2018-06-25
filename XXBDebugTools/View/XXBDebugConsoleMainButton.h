//
//  XXBDebugConsoleMainButton.h
//  XXBDebugToolsDemo
//
//  Created by xiaobing5 on 2018/4/26.
//  Copyright © 2018年 xiaobing5. All rights reserved.
//

#import <UIKit/UIKit.h>

#define XXBDEBUGCONSOLEMAINBUTTON_WIDTH              50  // 悬浮窗宽高
#define XXBDEBUGCONSOLEMAINBUTTON_TIMER_INTERVAL     1   // 每秒触发一次timer
#define XXBDEBUGCONSOLEMAINBUTTON_ROTATE_TIMER_COUNT 5   // 每5个timer周期触发一次旋转
#define XXBDEBUGCONSOLEMAINBUTTON_ALPAH_TIMER_COUNT  60  // 每60秒触发一次消失

@class XXBDebugConsoleMainButton;

@protocol XXBDebugConsoleMainButtonDelegate <NSObject>
/** 主按钮按下 */
- (void)debugConsoleMainButtonDidClicked:(XXBDebugConsoleMainButton *)button;

/** 主按钮开始拖拽 */
- (void)debugConsoleMainButtonDidBeginDragging:(XXBDebugConsoleMainButton *)button;

/** 主按钮停止拖拽 */
- (void)debugConsoleMainButtonDidEndDragging:(XXBDebugConsoleMainButton *)button;
@end

@interface XXBDebugConsoleMainButton : UIView

@property (nonatomic, weak) id<XXBDebugConsoleMainButtonDelegate>   delegate;

/** 设置显示文本 */
@property (nonatomic, copy) NSString                                *title;

/** 是否暂停动画计时 */
// 当显示了菜单时, 主按钮不应消失或旋转
@property (nonatomic, assign) BOOL                                  pausetimer;

/** 是否处在渐隐模式 */
@property(nonatomic, assign, readonly) BOOL                         isTransparent;

/** 显示背景动画 */
- (void)showBkAnimate;
@end
