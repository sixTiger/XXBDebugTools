//
//  XXBDebugBackupFuncSelView.m
//  XXBDebugToolsDemo
//
//  Created by xiaobing5 on 2018/4/26.
//  Copyright © 2018年 xiaobing5. All rights reserved.
//

#import "XXBDebugBackupFuncSelView.h"
#import "XXBDebugUtilityBackupFunc.h"
#import "XXBDebugUtility.h"

static XXBDebugBackupFuncSelView *g_DebugBackupFuncSelView = nil;

@interface XXBDebugBackupFuncSelView()<UITableViewDelegate,UITableViewDataSource>
{
    /** 列表视图 */
    UITableView                             *_tableView;
    
    /** 全部注册的备用测试功能 */
    NSArray <XXBDebugUtilityBackupFunc *>   *_arBackupFuncs;
    
    /** 已经启用的备用测试功能 */
    NSMutableArray                          *_arAvailableFuncs;
}
/** 点击取消 */
- (void)onClickCancel:(UIButton *)button;

/** 点击确定 */
- (void)onClickOK:(UIButton *)button;

/** 隐藏 */
- (void)hide;
@end
@implementation XXBDebugBackupFuncSelView
+ (void)show:(BOOL)show {
    if( g_DebugBackupFuncSelView ) {
        [g_DebugBackupFuncSelView hide];
    }
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    g_DebugBackupFuncSelView = [[self alloc] initWithFrame:window.frame];
    [window addSubview:g_DebugBackupFuncSelView];
}

#pragma mark - override

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if( self ) {
        self.backgroundColor = [UIColor whiteColor];
        
        // 导航条
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 64)];
        [self addSubview:header];
        header.backgroundColor = [UIColor colorWithRed:116/255.0 green:113/255.0 blue:191/255.0 alpha:0.96];
        
        // 标题
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(60, 20, frame.size.width - 120, 44)];
        label.font = [UIFont systemFontOfSize:15];
        label.textColor = [UIColor whiteColor];
        label.text = @"配置需要使用的测试功能";
        label.textAlignment = NSTextAlignmentCenter;
        [header addSubview:label];
        
        // 取消按钮
        UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 60, 44)];
        [cancelBtn setTitleColor:[[UIColor redColor] colorWithAlphaComponent:0.8] forState:UIControlStateNormal];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [header addSubview:cancelBtn];
        [cancelBtn addTarget:self action:@selector(onClickCancel:) forControlEvents:UIControlEventTouchUpInside];
        
        // 确认按钮
        UIButton *okBtn = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 60, 20, 60, 44)];
        [okBtn setTitleColor:[[UIColor blueColor] colorWithAlphaComponent:0.8] forState:UIControlStateNormal];
        [okBtn setTitle:@"确定" forState:UIControlStateNormal];
        [header addSubview:okBtn];
        [okBtn addTarget:self action:@selector(onClickOK:) forControlEvents:UIControlEventTouchUpInside];
        
        // 数据准备
        _arBackupFuncs = [XXBDebugUtility backupFuncs];
        if( !_arBackupFuncs.count ) {
            label.text = @"未注册备选测试功能";
        }
        _arAvailableFuncs = [[NSMutableArray alloc] init];
        for( XXBDebugUtilityBackupFunc *func in _arBackupFuncs ) {
            if( [XXBDebugUtility backupFuncAvailable:func.menuID] ) {
                [_arAvailableFuncs addObject:func.menuID];
            }
        }
        
        // 列表视图
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, frame.size.width, frame.size.height - 64)];
        [self addSubview:_tableView];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return self;
}


#pragma mark - self operations

/** 点击取消 */
- (void)onClickCancel:(UIButton *)button {
    [self hide];
}

/** 点击确定 */
- (void)onClickOK:(UIButton *)button {
    [XXBDebugUtility setAvailableBackupFuncIds:_arAvailableFuncs];
    [self hide];
}


/** 隐藏 */
- (void)hide {
    [self removeFromSuperview];
    if( g_DebugBackupFuncSelView == self ) {
        g_DebugBackupFuncSelView = nil;
    }
}

#pragma mark - table view delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _arBackupFuncs.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    NSInteger nCheckTag = 101;
    if( !cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        UILabel *checkLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 13, 18, 18)];
        checkLabel.font = [UIFont systemFontOfSize:12];
        checkLabel.tag = nCheckTag;
        [cell.contentView addSubview:checkLabel];
    }
    UILabel *checkLabel = (UILabel *)[cell viewWithTag:nCheckTag];
    
    XXBDebugUtilityBackupFunc *func = nil;
    if( indexPath.row < _arBackupFuncs.count ) {
        func = [_arBackupFuncs objectAtIndex:indexPath.row];
    }
    cell.textLabel.text = func.comment ? [NSString stringWithFormat:@"        %@", func.comment] : @"";
    if( [_arAvailableFuncs containsObject:func.menuID] ) {
        checkLabel.text = @"✅";
    } else {
        checkLabel.text = @"❌";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    XXBDebugUtilityBackupFunc *func = nil;
    if( indexPath.row < _arBackupFuncs.count ) {
        func = [_arBackupFuncs objectAtIndex:indexPath.row];
    }
    if( !func ) {
        return;
    }
    if( [_arAvailableFuncs containsObject:func.menuID] ) {
        [_arAvailableFuncs removeObject:func.menuID];
    } else {
        [_arAvailableFuncs addObject:func.menuID];
    }
    [_tableView reloadData];
}
@end
