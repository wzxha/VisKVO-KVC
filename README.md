# VisKVO-KVC
用objc库实现KVO、KVC

```objc
- (void)viewDidLoad {
    [super viewDidLoad];
    
    Foo * foo = [Foo new];
    
    foo.name = @"12";
    
    [foo vis_addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [foo vis_addObserver:self forKeyPath:@"asd" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
   
    foo.name = @"123";
    [foo vis_setValue:@"1234" forKey:@"name"];
    
    [foo vis_removeObserver:self forKeyPath:@"name"];
    
    [foo vis_setValue:@"12345" forKey:@"name"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"name"]) {
        NSLog(@"%@", change);
    }
}
```
```
log >
2017-03-09 15:22:58.159 Example[2045:217729] {
    new = 123;
    old = 123;
}
2017-03-09 15:22:58.159 Example[2045:217729] {
    new = 1234;
    old = 1234;
}
```
