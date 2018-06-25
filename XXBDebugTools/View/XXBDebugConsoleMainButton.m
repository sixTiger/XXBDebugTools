//
//  XXBDebugConsoleMainButton.m
//  XXBDebugToolsDemo
//
//  Created by xiaobing5 on 2018/4/26.
//  Copyright © 2018年 xiaobing5. All rights reserved.
//

#import "XXBDebugConsoleMainButton.h"
#import "XXBDebugUtilityConfig.h"

@interface XXBDebugConsoleMainButton()
{
    /** 背景图片 */
    CALayer     *_bkLayer;
    
    /** 背景图片的高光效果 */
    CALayer     *_bkHighlightLayer;
    
    /** 是否正在响应用户操作 */
    BOOL        _bTouching;
    
    /** 上一次触摸位置 */
    CGPoint     _ptPrevTouch;
    
    /** 触摸开始的位置 */
    CGPoint     _ptBeginTouch;
    
    /** 触摸遮罩 */
    UIView      *_touchingMask;
    
    /** 动画计时器 */
    NSTimer     *_timer;
    
    /** 旋转动画计数 */
    NSInteger   _nRotateTimerCount;
    
    /** 渐隐timer计数 */
    NSInteger   _nAlphaTimerCount;
    
    /** 显示文本 */
    UILabel     *_titleLabel;
    
    /** 是否进行了拖拽 */
    BOOL        _bDragged;
    
    /** 是否是半透明状态 */
    BOOL        _bTransparent;
}

/** 显示触摸遮罩 */
- (void)showTouchingMask:(BOOL)show;

/** 执行轻触事件 */
- (void)onClick;

/** 创建动画timer */
- (void)createAnimationTimer;

/** 清除动画timer */
- (void)clearAnimationTimer;

/** timer 触发事件 */
- (void)onTimerFired:(NSTimer *)timer;

/** 创建背景图片 */
- (UIImage *)createBkImage;

/** 创建背景图片的高光效果 */
- (UIImage *)createBkHighlightImage;

/** 显示半透明状态 */
- (void)setTransparent:(BOOL)transparent;

@end

@implementation XXBDebugConsoleMainButton

- (instancetype)initWithFrame:(CGRect)frame {
    CGRect rcScreen = [UIScreen mainScreen].bounds;
    CGPoint pt = [XXBDebugUtilityConfig consolePosition];
    if( CGPointEqualToPoint(pt, CGPointZero) )
    {
        frame.origin.x = rcScreen.size.width - XXBDEBUGCONSOLEMAINBUTTON_WIDTH - 10;
        frame.origin.y = 30;
    }
    else
    {
        frame.origin = pt;
    }
    frame.size.width = XXBDEBUGCONSOLEMAINBUTTON_WIDTH;
    frame.size.height = XXBDEBUGCONSOLEMAINBUTTON_WIDTH;
    
    if (self = [super initWithFrame:frame]) {
        self.layer.shadowOffset = CGSizeMake(5, 5);
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOpacity = 0.35;
        self.layer.shadowPath = CGPathCreateWithRoundedRect(self.bounds, XXBDEBUGCONSOLEMAINBUTTON_WIDTH / 2, XXBDEBUGCONSOLEMAINBUTTON_WIDTH / 2, &CGAffineTransformIdentity);
        
        // 创建背景图像
        _bkLayer = [CALayer layer];
        _bkLayer.frame = self.bounds;
        [self.layer addSublayer:_bkLayer];
        UIImage *img = [self createBkImage];
        _bkLayer.contents = (id)img.CGImage;
        _bkLayer.masksToBounds = YES;
        _bkLayer.cornerRadius = XXBDEBUGCONSOLEMAINBUTTON_WIDTH / 2;
        
        // 背景图像的高光效果
        _bkHighlightLayer = [CALayer layer];
        _bkHighlightLayer.frame = self.bounds;
        [self.layer addSublayer:_bkHighlightLayer];
        img = [self createBkHighlightImage];
        _bkHighlightLayer.contents = (id)img.CGImage;
        _bkHighlightLayer.masksToBounds = YES;
        _bkHighlightLayer.cornerRadius = _bkLayer.cornerRadius;
        
        // 触摸遮罩
        _touchingMask = [[UIView alloc] initWithFrame:self.bounds];
        _touchingMask.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.1];
        _touchingMask.hidden = YES;
        _touchingMask.layer.masksToBounds = YES;
        _touchingMask.layer.cornerRadius = _bkLayer.cornerRadius;
        [self addSubview:_touchingMask];
        
        // 标题文本
        _titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = @"🛠";
        [self addSubview:_titleLabel];
        
        [self createAnimationTimer];
    }
    return self;
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    [self clearAnimationTimer];
}

- (void)setFrame:(CGRect)frame {
    if( CGRectEqualToRect(frame, self.frame) ) {
        return;
    }
    [super setFrame:frame];
}

#pragma mark - touches

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    _ptPrevTouch = [touch locationInView:self.superview];
    _ptBeginTouch = _ptPrevTouch;
    _bDragged = NO;
    _bTouching = YES;
    [self showTouchingMask:YES];
    [self setTransparent:NO];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if( !_bDragged ) {
        [self onClick];
    }
    _bTouching = NO;
    
    [self showTouchingMask:NO];
    if( [_delegate respondsToSelector:@selector(debugConsoleMainButtonDidEndDragging:)] ) {
        [_delegate debugConsoleMainButtonDidEndDragging:self];
    }
    [XXBDebugUtilityConfig setConsolePosition:self.frame.origin];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint pt = [touch locationInView:self.superview];
    CGFloat fDx = pt.x - _ptPrevTouch.x;
    CGFloat fDy = pt.y - _ptPrevTouch.y;
    BOOL bDragged = _bDragged;
    if( fabs(fDx) > 5 || fabs(fDy) > 5 ) {
        _bDragged = YES;
    }
    
    if( fabs(pt.x - _ptBeginTouch.x) > 5 || fabs(pt.y - _ptBeginTouch.y) > 5 ) {
        _bDragged = YES;
    }
    
    if( !bDragged && _bDragged && [_delegate respondsToSelector:@selector(debugConsoleMainButtonDidBeginDragging:)] ) {
        [_delegate debugConsoleMainButtonDidBeginDragging:self];
    }
    
    _ptPrevTouch = pt;
    CGRect rcFrame = self.frame;
    rcFrame.origin.x += fDx;
    rcFrame.origin.y += fDy;
    if( rcFrame.origin.x < 0 ) {
        rcFrame.origin.x = 0;
    }
    if( rcFrame.origin.x + rcFrame.size.width > self.superview.bounds.size.width ) {
        rcFrame.origin.x = self.superview.bounds.size.width - rcFrame.size.width;
    }
    if( rcFrame.origin.y < 0 ) {
        rcFrame.origin.y = 0;
    }
    if( rcFrame.origin.y + rcFrame.size.height > self.superview.bounds.size.height ) {
        rcFrame.origin.y = self.superview.bounds.size.height - rcFrame.size.height;
    }
    self.frame = rcFrame;
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _bTouching = NO;
    [self showTouchingMask:NO];
    if( [_delegate respondsToSelector:@selector(debugConsoleMainButtonDidEndDragging:)] ) {
        [_delegate debugConsoleMainButtonDidEndDragging:self];
    }
}


#pragma mark - properties

/** 设置显示文本 */
- (void)setTitle:(NSString *)title {
    _titleLabel.text = title;
}

- (NSString *)title {
    return _titleLabel.text;
}

/** 是否暂停动画计时 */
// 当显示了菜单时, 主按钮不应消失或旋转
- (void)setPausetimer:(BOOL)pausetimer {
    if( pausetimer == _pausetimer ) {
        return;
    }
    _pausetimer = pausetimer;
    if( pausetimer ) {
        [self setTransparent:NO];
    }
}

/** 是否处在渐隐模式 */
- (BOOL)isTransparent {
    return _bTransparent;
}

#pragma mark - methods
/** 显示动画 */
- (void)showBkAnimate {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.fillMode = kCAFillModeBoth;
    animation.fromValue = [NSNumber numberWithFloat:0];
    animation.toValue = [NSNumber numberWithFloat:M_PI];
    if( arc4random() % 2 ) {
        animation.fromValue = [NSNumber numberWithFloat:M_PI];
        animation.toValue = [NSNumber numberWithFloat:0];
    }
    animation.removedOnCompletion = NO;
    animation.duration = 0.27;
    [_bkLayer addAnimation:animation forKey:@"0"];
}

#pragma mark - self operations

/** 显示触摸遮罩 */
- (void)showTouchingMask:(BOOL)show {
    _touchingMask.hidden = !show;
    if( show ) {
        self.transform = CGAffineTransformMakeScale(1.08, 1.08);
    } else {
        self.transform = CGAffineTransformIdentity;
    }
}

/** 执行轻触事件 */
- (void)onClick {
    if( [_delegate respondsToSelector:@selector(debugConsoleMainButtonDidClicked:)] ) {
        [_delegate debugConsoleMainButtonDidClicked:self];
    }
}

/** 创建动画timer */
- (void)createAnimationTimer {
    if( _timer ) {
        return;
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:XXBDEBUGCONSOLEMAINBUTTON_TIMER_INTERVAL target:self selector:@selector(onTimerFired:) userInfo:nil repeats:YES];
}

/** 清除动画timer */
- (void)clearAnimationTimer {
    if( _timer ) {
        [_timer invalidate];
        _timer = nil;
    }
}

/** timer 触发事件 */
- (void)onTimerFired:(NSTimer *)timer {
    if( _pausetimer ) {
        return;
    }
    if( !_bTouching ) {
        ++_nRotateTimerCount;
        if( _nRotateTimerCount >= XXBDEBUGCONSOLEMAINBUTTON_ROTATE_TIMER_COUNT ) {
            [self showBkAnimate];
            _nRotateTimerCount = 0;
        }
        if( !_bTransparent ) {
            ++_nAlphaTimerCount;
            if( _nAlphaTimerCount == XXBDEBUGCONSOLEMAINBUTTON_ALPAH_TIMER_COUNT ) {
                [self setTransparent:YES];
            }
        }
    }
}

/** 创建背景图片 */
- (UIImage *)createBkImage {
    CGFloat fScale = [UIScreen mainScreen].scale;
    CGSize imageSize = CGSizeMake(XXBDEBUGCONSOLEMAINBUTTON_WIDTH * fScale, XXBDEBUGCONSOLEMAINBUTTON_WIDTH * fScale);
    UIGraphicsBeginImageContext(imageSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 背景色
    CGContextSetRGBFillColor(context, 0.85, 0.85, 0.05, 0.65);
    CGContextFillRect(context, CGRectMake(0, 0, imageSize.width, imageSize.height));
    
    // 外圈边线
    CGMutablePathRef path = CGPathCreateMutable();
    CGContextSetLineWidth(context, 3);
    CGContextSetRGBStrokeColor(context,0.95,0.95,0.95,076);
    CGPathAddArc(path, &CGAffineTransformIdentity, imageSize.width / 2, imageSize.height / 2, imageSize.height / 2, 0, M_PI * 2, YES);
    CGContextAddPath(context, path);
    CGContextDrawPath(context, kCGPathStroke);
    CGPathRelease(path);
    
    // 外圈填充
    path = CGPathCreateMutable();
    CGContextSetLineWidth(context, 15);
    CGContextSetRGBStrokeColor(context, 0.95, 0.95, 0.95,0.88);
    CGPathAddArc(path, &CGAffineTransformIdentity, imageSize.width / 2, imageSize.height / 2, imageSize.height / 2 - 11, 0, M_PI * 2, YES);
    CGContextAddPath(context, path);
    CGContextDrawPath(context, kCGPathStroke);
    CGPathRelease(path);
    
    // 中部黑圈
    path = CGPathCreateMutable();
    CGContextSetLineWidth(context, 4);
    CGContextSetRGBStrokeColor(context, 0.25, 0.25, 0.25, 0.78);
    CGPathAddArc(path, &CGAffineTransformIdentity, imageSize.width / 2, imageSize.height / 2, imageSize.height / 2 - 12, 0, M_PI * 2, YES);
    CGContextAddPath(context, path);
    CGContextDrawPath(context, kCGPathStroke);
    CGPathRelease(path);
    
    // 内部蓝色填充
    path = CGPathCreateMutable();
    CGContextSetRGBFillColor(context, 116/255.0, 113/255.0, 191/255.0, 0.82);
    CGPathAddArc(path, &CGAffineTransformIdentity, imageSize.width / 2, imageSize.height / 2, imageSize.height / 2 - 14, 0, M_PI * 2, YES);
    CGContextAddPath(context, path);
    CGContextFillPath(context);
    CGPathRelease(path);
    
    // 弧形边线
    path = CGPathCreateMutable();
    CGContextSetLineWidth(context, 8);
    CGContextSetRGBStrokeColor(context, 0.64, 0.64, 0.64, 1);
    
    CGPathAddArc(path, &CGAffineTransformIdentity, imageSize.width / 2, imageSize.height / 2, imageSize.height / 2 - 5, -M_PI * 2 / 3, 0, NO);
    CGContextAddPath(context, path);
    CGPathRelease(path);
    
    path = CGPathCreateMutable();
    CGPathAddArc(path, &CGAffineTransformIdentity, imageSize.width / 2, imageSize.height / 2, imageSize.height / 2 - 5, M_PI / 3, M_PI, NO);
    CGContextAddPath(context, path);
    CGPathRelease(path);
    
    CGContextDrawPath(context, kCGPathStroke);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

/** 创建背景图片的高光效果 */
- (UIImage *)createBkHighlightImage
{
    
    CGFloat fScale = [UIScreen mainScreen].scale;
    CGSize imageSize = CGSizeMake(XXBDEBUGCONSOLEMAINBUTTON_WIDTH * fScale, XXBDEBUGCONSOLEMAINBUTTON_WIDTH * fScale);
    UIGraphicsBeginImageContext(imageSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGMutablePathRef path = CGPathCreateMutable();
    CGContextSetLineWidth(context, 1);
    CGContextSetRGBStrokeColor(context, 0.89, 0.89, 0.89, 1);
    //    CGPathAddArc(path, &CGAffineTransformIdentity, imageSize.width / 2, imageSize.height / 2, imageSize.height / 2 - 14, -M_PI_2 * 0.8, -M_PI_2 * 0.3, NO);
    CGPathAddArc(path, &CGAffineTransformIdentity, imageSize.width / 2, imageSize.height / 2, imageSize.height / 2 - 14, 0, M_PI * 2, NO);
    CGContextAddPath(context, path);
    CGContextDrawPath(context, kCGPathStroke);
    CGPathRelease(path);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}


/** 显示半透明状态 */
- (void)setTransparent:(BOOL)transparent {
    if( !transparent ) {
        _nAlphaTimerCount = 0;
    }
    if( transparent == _bTransparent ) {
        return;
    }
    _bTransparent = transparent;
    [UIView animateWithDuration:0.1 animations:^{
        if( transparent ) {
            self.alpha = 0.2;
        } else {
            self.alpha = 1;
        }
    }];
}

@end
