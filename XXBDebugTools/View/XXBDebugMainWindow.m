//
//  XXBDebugMainWindow.m
//  XXBDebugToolsDemo
//
//  Created by xiaobing5 on 2018/4/25.
//  Copyright © 2018年 xiaobing5. All rights reserved.
//

#import "XXBDebugMainWindow.h"
#import "XXBDebugConsole.h"


@interface XXBDebugMainWindow()

/**
 上一次hitTest的时间 用于判定是否将主按钮从渐隐模式恢复
 */
@property(nonatomic, strong) NSDate    *prevHitTestDate;

@end;

@implementation XXBDebugMainWindow

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.rootViewController = [[UIViewController alloc] init];
        self.rootViewController.view.backgroundColor = [UIColor clearColor];
        self.rootViewController.view.userInteractionEnabled = NO;
        self.rootViewController.view.frame = self.bounds;
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *ret = [super hitTest:point withEvent:event];
    if( ret == self || ret == self.rootViewController.view ) {
        [[[XXBDebugConsole share] mainMenu] unpopIfUnlocked];
        return nil;
    }
    if( [[XXBDebugConsole share] isTransparent] ) {
        BOOL canRecover = NO;
        // 主按钮已进入渐隐模式
        NSDate *date = [NSDate date];
        if( _prevHitTestDate && [date timeIntervalSinceDate:_prevHitTestDate] < 0.45 ) {
            canRecover = YES;
        }
        _prevHitTestDate = date;
        if( !canRecover ) {
            return nil;
        }
    }
    return ret;
}

- (void)addSubview:(UIView *)view {
    [super addSubview:view];
    if( view != self.rootViewController.view ) {
    }
}

- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index {
    [super insertSubview:view atIndex:index];
}

- (void)insertSubview:(UIView *)view aboveSubview:(UIView *)siblingSubview {
    [super insertSubview:view aboveSubview:siblingSubview];
}

- (void)insertSubview:(UIView *)view belowSubview:(UIView *)siblingSubview {
    [super insertSubview:view belowSubview:siblingSubview];
}


- (void)becomeKeyWindow {
    // 避免成为keyWindow
    [[UIApplication sharedApplication].delegate.window makeKeyWindow];
}

#pragma mark - methods
/**
 添加debug控件
 
 @param subview 添加debug控件
 */
- (void)addDebugComponent:(UIView *)subview {
    [super addSubview:subview];
}
@end
