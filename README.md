# VisKVO-KVC
用objc库实现KVO、KVC

## Test

```objc

@interface Foo : NSObject

@property (nonatomic, copy) NSString *bar;

@property (nonatomic, copy) NSString *name;

@end

@implementation Foo

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"bar"]) {
        self.name = change[@"new"];
    }
}

@end
```

```objc
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
```
