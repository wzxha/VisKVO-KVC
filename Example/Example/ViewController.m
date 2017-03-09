//
//  ViewController.m
//  Example
//
//  Created by WzxJiang on 17/3/9.
//  Copyright © 2017年 wzxjiang. All rights reserved.
//

#import "ViewController.h"
#import "Foo.h"
#import "NSObject+VisKVC.h"
#import "NSObject+VisKVO.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Foo * foo = [Foo new];
    
    foo.name = @"12";
    
    [foo vis_addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
   
    [foo vis_setValue:@"123" forKey:@"name"];
    
    [foo vis_removeObserver:self forKeyPath:@"name"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"name"]) {
        NSLog(@"%@", change);
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
