//
//  XXBDebugMenuTitle.m
//  XXBDebugToolsDemo
//
//  Created by xiaobing5 on 2018/4/26.
//  Copyright © 2018年 xiaobing5. All rights reserved.
//

#import "XXBDebugMenuTitleView.h"
#import "XXBDebugConsoleMainButton.h"

@interface XXBDebugMenuTitleView()
{
    UILabel     *_titleLabel;
}

/**
 开始显示的点
 */
@property (nonatomic, assign) CGPoint ptFrom;

/**
 调整尺寸
 */
- (void)adjustSize;
@end

@implementation XXBDebugMenuTitleView

#pragma makr - properties

/**
 设置最大宽度

 @param maxWidth 最大宽度
 */
- (void)setMaxWidth:(CGFloat)maxWidth {
    _maxWidth = maxWidth;
    [self adjustSize];
}

#pragma mark - override
- (instancetype)initWithFrame:(CGRect)frame {
    if( self = [super initWithFrame:frame] ) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.backgroundColor = [UIColor colorWithRed:116/255.0 green:113/255.0 blue:191/255.0 alpha:0.96];
        _titleLabel.layer.masksToBounds = YES;
        _titleLabel.layer.borderColor = [UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:1].CGColor;
        _titleLabel.layer.borderWidth = 2;
        _titleLabel.layer.cornerRadius = 4;
        _titleLabel.userInteractionEnabled = YES;
        [self addSubview:_titleLabel];
        
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(5, 5);
        self.layer.shadowOpacity = 0.35;
        
        self.alpha = 0;
    }
    return self;
}


#pragma mark - properties

/** 设置选中状态 */
- (void)setSelected:(BOOL)selected {
    if( selected == _selected ) {
        return;
    }
    _selected = selected;
    UIColor *bkColor = [UIColor colorWithRed:116/255.0 green:113/255.0 blue:191/255.0 alpha:0.96];
    _titleLabel.backgroundColor = selected ? [bkColor colorWithAlphaComponent:0.6] : bkColor;
}

/** 文本内容 */
- (NSString *)text {
    return _titleLabel.text;
}

- (void)setText:(NSString *)text {
    _titleLabel.text = text;
    [self adjustSize];
}

/** 字体 */
- (UIFont *)font {
    return _titleLabel.font;
}

- (void)setFont:(UIFont *)font {
    _titleLabel.font = font;
    [self adjustSize];
}

#pragma mark - methods

/**
 显示
 
 @param point 显示在对应的点
 */
- (void)showFromPoint:(CGPoint)point {
    CGRect rcFrame = self.bounds;
    if( point.x - rcFrame.size.width / 2 < 0 ) {
        point.x = rcFrame.size.width / 2;
    }
    if( point.x + rcFrame.size.width / 2 > self.superview.bounds.size.width ) {
        point.x = self.superview.bounds.size.width - rcFrame.size.width / 2;
    }
    _ptFrom = point;
    self.center = point;
    CGFloat fAdjust = 0;
    if( point.y - self.bounds.size.height - XXBDEBUGCONSOLEMAINBUTTON_WIDTH / 2 < 20 ) {
        fAdjust = XXBDEBUGCONSOLEMAINBUTTON_WIDTH / 2 + rcFrame.size.height / 2;
    } else {
        fAdjust = -(XXBDEBUGCONSOLEMAINBUTTON_WIDTH / 2 + rcFrame.size.height / 2);
    }
    if( _revertPosition ) {
        fAdjust = -fAdjust;
    }
    point.y += fAdjust;
    
    [self.superview bringSubviewToFront:self];
    [UIView animateWithDuration:0.22 animations:^{
        self.alpha = 1;
        self.center = point;
    }];
}

/** 隐藏 */
- (void)hide {
    [UIView animateWithDuration:0.22 animations:^{
        self.alpha = 0;
        self.center = self.ptFrom;
    }];
}

#pragma mark - self operations

/** 调整尺寸 */
- (void)adjustSize {
    CGPoint center = self.center;
    CGRect textRect = [self.text boundingRectWithSize:CGSizeMake(_maxWidth, CGFLOAT_MAX)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:[NSDictionary dictionaryWithObjectsAndKeys:_titleLabel.font, NSFontAttributeName, nil]
                                              context:nil];
    textRect.origin.x = 0;
    textRect.origin.y = 0;
    textRect.size.width += 10;
    textRect.size.height += 10;
    self.frame = textRect;
    self.center = center;
    _titleLabel.frame = self.bounds;
    self.layer.shadowPath = CGPathCreateWithRoundedRect(self.bounds, 4, 4, &CGAffineTransformIdentity);
}


#pragma mark - touches

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.selected = YES;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if( self.selected ) {
        if( [_delegate respondsToSelector:@selector(debugMenuTitleDidClick:)] ) {
            [_delegate debugMenuTitleDidClick:self];
        }
    }
    self.selected = NO;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint pt = [touch locationInView:self];
    self.selected = CGRectContainsPoint(self.bounds, pt);
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.selected = NO;
}
@end
