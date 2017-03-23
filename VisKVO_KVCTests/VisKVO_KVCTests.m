//
//  VisKVO_KVCTests.m
//  VisKVO_KVCTests
//
//  Created by WzxJiang on 17/3/23.
//  Copyright © 2017年 wzxjiang. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Foo.h"
@import VisKVO_KVC;

@interface VisKVO_KVCTests : XCTestCase

@property (nonatomic, strong) Foo *foo;

@end

@implementation VisKVO_KVCTests

- (void)setUp {
    [super setUp];
    self.foo = [Foo new];
    
    [self.foo vis_addObserver:self.foo forKeyPath:@"bar" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)testExample {
    
    // KVC
    [self.foo vis_setValue:@"bar1" forKey:@"bar"];
    XCTAssertTrue([@"bar1" isEqualToString:self.foo.bar], @"[Vis_KVC]: self.foo.bar must be 'bar1'");
    
    NSString * bar = [self.foo vis_valueForKey:@"bar"];
    XCTAssertTrue([@"bar1" isEqualToString:bar], @"[Vis_KVC]: bar must be 'bar1'");
    
 
    // KVO
    XCTAssertTrue([@"bar1" isEqualToString:self.foo.name], @"[Vis_KVO]: self.foo.name must be 'bar1'");
    
    
    [self.foo vis_removeObserver:self.foo forKeyPath:@"bar"];
    [self.foo vis_setValue:@"bar2" forKey:@"bar"];
    
    XCTAssertTrue([@"bar1" isEqualToString:self.foo.name], @"[Vis_KVO]: self.foo.name must be 'bar1'");
}

@end
