//
//  ViewController.m
//  XXBDebugToolsDemo
//
//  Created by xiaobing5 on 2018/4/25.
//  Copyright © 2018年 xiaobing5. All rights reserved.
//

#import "ViewController.h"
#import "XXBDebugUtility.h"

@interface ViewController ()
@property(nonatomic, weak) UIImageView  *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [XXBDebugUtility showConsole:YES]; 
    [self setupdateDebugUtil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupdateDebugUtil {
    [self addNetWork];
    [self addNetWorkDispatchFunctions];
}


- (void)addNetWork {
    // 一级菜单
    [XXBDebugUtility addDebugButtonWithID:@"1-0"
                             parentButton:nil
                                    title:@"🕸 网络功能"
                                   action:nil];
    
    // 二级菜单
    [XXBDebugUtility addDebugButtonWithID:@"1-0-0"
                             parentButton:@"1-0"
                                    title:@"🗄 选择服务器"
                                   action:^(NSString *buttonID){
                                       NSLog(@"🗄 选择服务器");
                                   }];
    [XXBDebugUtility addDebugButtonWithID:@"1-0-1" parentButton:@"1-0" title:@"🔐 加密URL" action:^(NSString *buttonID) {
        NSLog(@"XXB: 🔐 加密URL");
    }];
    
    // 三级菜单
    
    [XXBDebugUtility addDebugButtonWithID:@"1-0-0-0" parentButton:@"1-0-0" title:@"🌍服务器 0" action:^(NSString *buttonID) {
        NSLog(@"🌍服务器 0");
    }];
    
    [XXBDebugUtility addDebugButtonWithID:@"1-0-0-1" parentButton:@"1-0-0" title:@"🌍服务器 1" action:^(NSString *buttonID) {
        NSLog(@"🌍服务器 1");
    }];
    
    [XXBDebugUtility addDebugButtonWithID:@"1-0-0-2" parentButton:@"1-0-0" title:@"🌍服务器 2" action:^(NSString *buttonID) {
        NSLog(@"🌍服务器 2");
    }];
}

- (void)addNetWorkDispatchFunctions {
    [XXBDebugUtility registerBackupFunction:@"1-1" comment:@"网络优先级测试" openBlock:^{
        [XXBDebugUtility addDebugButtonWithID:@"1-1" parentButton:nil title:@"🗜 网络优先级测试" action:^(NSString *buttonID) {
            NSLog(@"XXB | %s [Line %d] %@",__func__,__LINE__,@"网络优先级测试");
        }];
        [XXBDebugUtility addDebugButtonWithID:@"1-1-0" parentButton:@"1-1" title:@"加载最新日志" action:^(NSString *buttonID) {
            NSLog(@"XXB | %s [Line %d] %@",__func__,__LINE__,@"加载最新日志");
        }];
    }];
}
@end
