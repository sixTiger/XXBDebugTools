//
//  XXBDebugMenuItem.m
//  XXBDebugToolsDemo
//
//  Created by xiaobing5 on 2018/4/26.
//  Copyright © 2018年 xiaobing5. All rights reserved.
//

#import "XXBDebugMenuItemView.h"

@interface XXBDebugMenuItemView()<CAAnimationDelegate>
{
    /** 背景图片 */
    UIImageView     *_bkImageView;
    
    /** 标题 */
    UILabel         *_titleLabel;
    
    /** 上次显示的起点 */
    CGPoint         _ptPrevStart;
    
    /** 上次显示的终点 */
    CGPoint         _ptPrevEnd;
    
    /** 选中状态 */
    UILabel         *_checkMask;
    
    /** 是否有下级菜单标识 */
    UILabel         *_submenuMask;
}

/** 计算文本和自身尺寸 */
- (void)adjustForTitle;

/** 执行动画 */
- (void)launchAnimationForShow:(BOOL)show;

/** 根据rect尺寸计算起终点连线与边界的交点(相对于自身坐标系) */
- (CGPoint)crossPointForSize:(CGSize)size;

/** 绘制并计算背景图片 */
- (void)drawBkgndImage;
@end
@implementation XXBDebugMenuItemView

- (instancetype)initWithFrame:(CGRect)frame {
    if( self = [super initWithFrame:frame] ) {
        // 背景图片
        _bkgndColor = [UIColor colorWithRed:116/255.0 green:113/255.0 blue:191/255.0 alpha:0.96];
        _bkImageView = [[UIImageView alloc] init];
        _bkImageView.layer.shadowOffset = CGSizeMake(5, 5);
        _bkImageView.layer.shadowColor = [UIColor blackColor].CGColor;
        _bkImageView.layer.shadowOpacity = 0.35;
        [self addSubview:_bkImageView];
        
        // 标题
        _titleLabel = [[UILabel alloc] init];
        [self addSubview:_titleLabel];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 0;
        
        // 选中标识
        _checkMask = [[UILabel alloc] initWithFrame:CGRectMake(-8, -8, 22, 22)];
        _checkMask.textAlignment = NSTextAlignmentCenter;
        _checkMask.font = [UIFont systemFontOfSize:14];
        _checkMask.text = @"✅";
        _checkMask.alpha = 0.7;
        _checkMask.layer.masksToBounds = YES;
        _checkMask.layer.cornerRadius = _checkMask.bounds.size.width / 2;
        [self addSubview:_checkMask];
        _checkMask.hidden = YES;
        
        // 下级菜单
        _submenuMask = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 18, 18)];
        _submenuMask.textAlignment = NSTextAlignmentCenter;
        _submenuMask.font = [UIFont systemFontOfSize:12];
        _submenuMask.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
        _submenuMask.text = @"➤";
        _submenuMask.layer.shadowColor = [UIColor blackColor].CGColor;
        _submenuMask.layer.shadowOffset = CGSizeMake(-3, 3);
        _submenuMask.layer.shadowOpacity = 0.65;
        [self addSubview:_submenuMask];
        _submenuMask.hidden = YES;
        
        self.maxWidth = 0;
        
        _subItems = [[NSMutableArray alloc] init];
        
        self.hidden = YES;
    }
    return self;
}

#pragma mark - properties

/** 最大宽度 */
- (void)setMaxWidth:(CGFloat)maxWidth {
    if( maxWidth <= 0 ) {
        maxWidth = 1024;
    }
    if( maxWidth == _maxWidth ) {
        return;
    }
    _maxWidth = maxWidth;
    [self adjustForTitle];
}

/** 最小宽度 */
- (void)setMinWidth:(CGFloat)minWidth {
    if( minWidth < 0 ) {
        minWidth = 0;
    }
    if( minWidth == _minWidth ) {
        return;
    }
    _minWidth = minWidth;
    [self adjustForTitle];
}

/** 设置高亮状态 */
- (void)setHighlighted:(BOOL)highlighted {
    if( highlighted == _highlighted ) {
        return;
    }
    _highlighted = highlighted;
    _bkImageView.alpha = highlighted ? 0.6 : 1;
}

/** 选中状态 */
- (void)setChecked:(BOOL)checked {
    _checked = checked;
    _checkMask.hidden = !checked;
}

/** 标题文本 */
- (NSString *)title {
    return _titleLabel.text;
}

- (void)setTitle:(NSString *)title {
    if( [title isEqualToString:_titleLabel.text] ) {
        return;
    }
    _titleLabel.text = title;
    _bkImageView.image = nil;
    [self adjustForTitle];
    if( _onShow ) {
        [self drawBkgndImage];
    }
}

/** 标题颜色 */
- (UIColor *)titleColor {
    return _titleLabel.textColor;
}

- (void)setTitleColor:(UIColor *)titleColor {
    _titleLabel.textColor = titleColor;
}

- (void)setBkgndColor:(UIColor *)bkgndColor {
    _bkgndColor = bkgndColor;
    if( _onShow ) {
        [self drawBkgndImage];
    }
}

#pragma mark - methods
/** 展开菜单项 */
- (void)openMenuItemFromPoint:(CGPoint)ptFrom toPoint:(CGPoint)ptEnd {
    if( _onShow ) {
        return;
    }
    [self.layer removeAllAnimations];
    if( !_bkImageView.image || !CGPointEqualToPoint(ptFrom, _ptPrevStart) || !CGPointEqualToPoint(ptEnd, _ptPrevEnd) ) {
        _ptPrevStart = ptFrom;
        _ptPrevEnd = ptEnd;
        // 与上次展示的位置不同, 重新绘制背景
        [self drawBkgndImage];
    }
    self.center = ptEnd;
    _submenuMask.hidden = _subItems.count <= 0;
    [self launchAnimationForShow:YES];
    self.backgroundColor = [UIColor redColor];
}

/** 关闭菜单项 */
- (void)closeMenuItem {
    [self launchAnimationForShow:NO];
}


/** 获取指定id的子菜单 */
- (XXBDebugMenuItemView *)subitemWithID:(NSString *)identifier {
    for( XXBDebugMenuItemView *subitem in _subItems ) {
        if( [subitem.identifier isEqualToString:identifier] ) {
            return subitem;
        }
        XXBDebugMenuItemView *grandSubitem = [subitem subitemWithID:identifier];
        if( grandSubitem ) {
            return grandSubitem;
        }
    }
    return nil;
}

/** 移除指定id的子菜单 */
- (BOOL)removeSubitemWithID:(NSString *)identifier {
    for( XXBDebugMenuItemView *subitem in _subItems ) {
        if( [subitem.identifier isEqualToString:identifier] ) {
            [subitem removeFromSuperview];
            [_subItems removeObject:subitem];
            return YES;
        }
        if( [subitem removeSubitemWithID:identifier] ) {
            return YES;
        }
    }
    return NO;
}

/** 添加一个子菜单 */
- (void)addSubitem:(XXBDebugMenuItemView *)subitem {
    subitem.parentItem = self;
    [_subItems addObject:subitem];
}

/** 取消所有子菜单的选中状态 */
- (void)uncheckAllSubitems {
    for( XXBDebugMenuItemView *subitem in _subItems )
    {
        subitem.checked = NO;
    }
}

#pragma mark - touches

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.highlighted = YES;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if( self.highlighted ) {
        if( [_delegate respondsToSelector:@selector(menuItemDidClicked:)] ) {
            [_delegate menuItemDidClicked:self];
        } if( _clickBlock ) {
            _clickBlock(_identifier);
        }
    }
    self.highlighted = NO;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint pt = [touch locationInView:self];
    self.highlighted = CGRectContainsPoint(self.bounds, pt);
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.highlighted = NO;
}

#pragma mark - self operations
/** 计算文本和自身尺寸 */
- (void)adjustForTitle {
    CGPoint center = self.center;
    CGRect textRect = [_titleLabel.text boundingRectWithSize:CGSizeMake(_maxWidth - XXBDEBUGMENUITEM_EDGE_WIDTH * 2, CGFLOAT_MAX)
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:[NSDictionary dictionaryWithObjectsAndKeys:_titleLabel.font, NSFontAttributeName, nil]
                                                     context:nil];
    textRect.origin.x = XXBDEBUGMENUITEM_EDGE_WIDTH;
    textRect.origin.y = XXBDEBUGMENUITEM_EDGE_WIDTH;
    if( _minWidth < _maxWidth && textRect.size.width < _minWidth ) {
        textRect.size.width = _minWidth;
    }
    _titleLabel.frame = textRect;
    textRect.size.width += XXBDEBUGMENUITEM_EDGE_WIDTH * 2;
    textRect.size.height += XXBDEBUGMENUITEM_EDGE_WIDTH * 2;
    self.frame = textRect;
    self.center = center;
    
    CGRect rcSubmenuMask = _submenuMask.frame;
    rcSubmenuMask.origin.x = self.bounds.size.width - rcSubmenuMask.size.width / 2;
    rcSubmenuMask.origin.y = (self.bounds.size.height - rcSubmenuMask.size.height) / 2;
    _submenuMask.frame = rcSubmenuMask;
}

/** 执行动画 */
- (void)launchAnimationForShow:(BOOL)show {
    _onShow = show;
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animationGroup.fillMode = kCAFillModeBoth;
    animationGroup.removedOnCompletion = NO;
    animationGroup.duration = XXBDEBUGMENUITEM_ANIMATION_TIME;
    animationGroup.delegate = self;
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
    CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    if( show ) {
        scaleAnimation.fromValue = [NSNumber numberWithFloat:0];
        scaleAnimation.toValue = [NSNumber numberWithFloat:1];
        positionAnimation.fromValue = [NSValue valueWithCGPoint:_ptPrevStart];
        positionAnimation.toValue = [NSValue valueWithCGPoint:_ptPrevEnd];
    } else {
        scaleAnimation.fromValue = [NSNumber numberWithFloat:1];
        scaleAnimation.toValue = [NSNumber numberWithFloat:0];
        positionAnimation.fromValue = [NSValue valueWithCGPoint:_ptPrevEnd];
        positionAnimation.toValue = [NSValue valueWithCGPoint:_ptPrevStart];
    }
    
    animationGroup.animations = [NSArray arrayWithObjects:scaleAnimation, positionAnimation, nil];
    [self.layer addAnimation:animationGroup forKey:@"0"];
}

/** 根据rect尺寸计算起终点连线与边界的交点(相对于自身坐标系) */
- (CGPoint)crossPointForSize:(CGSize)size {
    CGPoint ptEdge;
    CGFloat fDHeight = _ptPrevEnd.y - _ptPrevStart.y;       // y轴位移
    CGFloat fDWidth = _ptPrevEnd.x - _ptPrevStart.x;        // x轴位移
    CGFloat fTan;                // 起终点连线与x轴夹角的正切
    if( 0 != fDWidth ) {
        fTan = fabs(fDHeight / fDWidth);
        ptEdge.y = (size.width / 2) * fTan;
        if( ptEdge.y > size.height / 2 ) {
            // 交点在宽度线
            ptEdge.y = size.height / 2;
            ptEdge.x = ptEdge.y / fTan;
        } else {
            // 交点在高度线
            ptEdge.x = size.width / 2;
        }
    } else {
        // 垂直
        ptEdge.y = size.height / 2;
        ptEdge.x = 0;
    }
    if( fDHeight > 0 ) {
        ptEdge.y = -ptEdge.y;
    }
    if( fDWidth > 0 ) {
        ptEdge.x = -ptEdge.x;
    }
    ptEdge.x += self.center.x;
    ptEdge.y += self.center.y;
    ptEdge.x -= self.frame.origin.x;
    ptEdge.y -= self.frame.origin.y;
    return ptEdge;
}

/** 绘制并计算背景图片 */
- (void)drawBkgndImage {
    CGFloat fEdgeStep = 7;      // 夹角在视图边界上的半宽度
    CGRect rcImage = self.bounds;
    rcImage.size.width += XXBDEBUGMENUITEM_BKIMAGE_EDGE * 2;
    rcImage.size.height += XXBDEBUGMENUITEM_BKIMAGE_EDGE * 2;
    rcImage.origin.x = -XXBDEBUGMENUITEM_BKIMAGE_EDGE;
    rcImage.origin.y = -XXBDEBUGMENUITEM_BKIMAGE_EDGE;
    _bkImageView.frame = rcImage;
    
    CGFloat fScale = 1;//[UIScreen mainScreen].scale;
    CGSize imageSize = rcImage.size;
    imageSize.width *= fScale;
    imageSize.height *= fScale;
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPoint ptPointer = [self crossPointForSize:rcImage.size];      // 尖角顶点
    ptPointer.x += XXBDEBUGMENUITEM_BKIMAGE_EDGE;
    ptPointer.y += XXBDEBUGMENUITEM_BKIMAGE_EDGE;
    
    CGPathMoveToPoint(path, &CGAffineTransformIdentity, ptPointer.x, ptPointer.y);
    
    CGPoint ptEdge = [self crossPointForSize:self.bounds.size];     // 与视图边界交点
    CGPoint ptEdge1 = ptEdge;        // 尖角与视图连线点1
    CGPoint ptEdge2 = ptEdge;        // 尖角与视图连线点2
    
#define __CODE_ADD_POINT_LEFTUP_    CGPathAddLineToPoint(path, &CGAffineTransformIdentity, XXBDEBUGMENUITEM_BKIMAGE_EDGE, XXBDEBUGMENUITEM_BKIMAGE_EDGE)
#define __CODE_ADD_POINT_RIGHTUP_   CGPathAddLineToPoint(path, &CGAffineTransformIdentity, XXBDEBUGMENUITEM_BKIMAGE_EDGE + self.bounds.size.width, XXBDEBUGMENUITEM_BKIMAGE_EDGE)
#define __CODE_ADD_POINT_RIGHTBOTTOM_   CGPathAddLineToPoint(path, &CGAffineTransformIdentity, XXBDEBUGMENUITEM_BKIMAGE_EDGE + self.bounds.size.width, XXBDEBUGMENUITEM_BKIMAGE_EDGE + self.bounds.size.height)
#define __CODE_ADD_POINT_LEFTBOTTOM_    CGPathAddLineToPoint(path, &CGAffineTransformIdentity, XXBDEBUGMENUITEM_BKIMAGE_EDGE, XXBDEBUGMENUITEM_BKIMAGE_EDGE + self.bounds.size.height)
#define __CODE_ADD_POINT_2_    CGPathAddLineToPoint(path, &CGAffineTransformIdentity, ptEdge2.x + XXBDEBUGMENUITEM_BKIMAGE_EDGE, ptEdge2.y + XXBDEBUGMENUITEM_BKIMAGE_EDGE)
    
#define __CODE_ADD_POINT_1_     CGPathAddLineToPoint(path, &CGAffineTransformIdentity, ptEdge1.x + XXBDEBUGMENUITEM_BKIMAGE_EDGE, ptEdge1.y + XXBDEBUGMENUITEM_BKIMAGE_EDGE)
    if( 0 == ptEdge.x ) {
        // 交点在左侧
        ptEdge2.y -= fEdgeStep;
        if( ptEdge2.y < 0 ) {
            ptEdge2.x = -ptEdge2.y;
            ptEdge2.y = 0;
            // 尖角右侧点
            __CODE_ADD_POINT_2_;
        } else {
            // 尖角右侧点
            __CODE_ADD_POINT_2_;
            // 菜单项左上角
            __CODE_ADD_POINT_LEFTUP_;
        }
        // 菜单项右上角
        __CODE_ADD_POINT_RIGHTUP_;
        // 菜单项右下角
        __CODE_ADD_POINT_RIGHTBOTTOM_;
        
        ptEdge1.y += fEdgeStep;
        if( ptEdge1.y > self.bounds.size.height ) {
            ptEdge1.x += ptEdge1.y - self.bounds.size.height;
            ptEdge1.y = self.bounds.size.height;
            // 尖角左侧点
            __CODE_ADD_POINT_1_;
        } else {
            // 菜单项左下角
            __CODE_ADD_POINT_LEFTBOTTOM_;
            // 尖角左侧点
            __CODE_ADD_POINT_1_;
        }
    } else if( 0 == ptEdge.y ) {
        // 交点在顶部
        ptEdge2.x += fEdgeStep;
        if( ptEdge2.x > self.bounds.size.width ) {
            ptEdge2.y = ptEdge2.x - self.bounds.size.width;
            ptEdge2.x = self.bounds.size.width;
            // 尖角右侧点
            __CODE_ADD_POINT_2_;
        } else {
            // 尖角右侧点
            __CODE_ADD_POINT_2_;
            // 菜单项右上角
            __CODE_ADD_POINT_RIGHTUP_;
        }
        // 菜单项右下角
        __CODE_ADD_POINT_RIGHTBOTTOM_;
        // 菜单项左下角
        __CODE_ADD_POINT_LEFTBOTTOM_;
        
        ptEdge1.x -= fEdgeStep;
        if( ptEdge1.x < 0 ) {
            ptEdge1.y = -ptEdge1.x;
            ptEdge1.x = 0;
            // 尖角左侧点
            __CODE_ADD_POINT_1_;
        } else {
            // 菜单项左上角
            __CODE_ADD_POINT_LEFTUP_;
            // 尖角左侧点
            __CODE_ADD_POINT_1_;
        }
    } else if( fabs(ptEdge.x - self.bounds.size.width) < 0.05 ) {
        // 交点在右侧
        ptEdge2.y += fEdgeStep;
        if( ptEdge2.y > self.bounds.size.height ) {
            ptEdge2.x -= ptEdge2.y - self.bounds.size.height;
            ptEdge2.y = self.bounds.size.height;
            // 尖角右侧点
            __CODE_ADD_POINT_2_;
        } else {
            // 尖角右侧点
            __CODE_ADD_POINT_2_;
            // 菜单项右下角
            __CODE_ADD_POINT_RIGHTBOTTOM_;
        }
        // 菜单项左下角
        __CODE_ADD_POINT_LEFTBOTTOM_;
        // 菜单项左上角
        __CODE_ADD_POINT_LEFTUP_;
        
        ptEdge1.y -= fEdgeStep;
        if( ptEdge1.y < 0 ) {
            ptEdge1.x += ptEdge1.y;
            ptEdge1.y = 0;
            // 尖角左侧点
            __CODE_ADD_POINT_1_;
        } else {
            // 菜单项右上角
            __CODE_ADD_POINT_RIGHTUP_;
            // 尖角左侧点
            __CODE_ADD_POINT_1_;
        }
    } else if( fabs(ptEdge.y - self.bounds.size.height) < 0.05 ) {
        // 交点在底部
        ptEdge2.x -= fEdgeStep;
        if( ptEdge2.x < 0 ) {
            ptEdge2.y += ptEdge2.x;
            ptEdge2.x = 0;
            // 尖角右侧点
            __CODE_ADD_POINT_2_;
        } else {
            // 尖角右侧点
            __CODE_ADD_POINT_2_;
            // 菜单项左下角
            __CODE_ADD_POINT_LEFTBOTTOM_;
        }
        // 菜单项左上角
        __CODE_ADD_POINT_LEFTUP_;
        // 菜单项右上角
        __CODE_ADD_POINT_RIGHTUP_;
        ptEdge1.x += fEdgeStep;
        if( ptEdge1.x > self.bounds.size.width ) {
            ptEdge1.y += self.bounds.size.width - ptEdge1.x;
            ptEdge1.x = self.bounds.size.width;
            // 尖角左侧点
            __CODE_ADD_POINT_1_;
        } else {
            // 菜单项右下角
            __CODE_ADD_POINT_RIGHTBOTTOM_;
            // 尖角左侧点
            __CODE_ADD_POINT_1_;
        }
    }
    
#undef __CODE_ADD_POINT_LEFTUP_
#undef __CODE_ADD_POINT_RIGHTUP_
#undef __CODE_ADD_POINT_RIGHTBOTTOM_
#undef __CODE_ADD_POINT_LEFTBOTTOM_
#undef __CODE_ADD_POINT_2_
#undef __CODE_ADD_POINT_1_
    
    CGPathAddLineToPoint(path, &CGAffineTransformIdentity, ptPointer.x, ptPointer.y);
    UIGraphicsBeginImageContext(imageSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 0.89, 0.89, 0.89, 1);
    CGContextSetFillColorWithColor(context, _bkgndColor.CGColor);
    CGContextAddPath(context, path);
    CGContextFillPath(context);
    CGContextSetLineWidth(context, 2);
    CGContextAddPath(context, path);
    CGContextDrawPath(context, kCGPathStroke);
    _bkImageView.layer.shadowPath = path;
    CGPathRelease(path);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    _bkImageView.image = img;
}

#pragma mark - animation delegate
- (void)animationDidStart:(CAAnimation *)anim {
    if( _onShow ) {
        self.hidden = NO;
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if( !flag ) {
        return;
    }
    if( !_onShow ) {
        self.hidden = YES;
    }
    [self.layer removeAllAnimations];
}
@end
