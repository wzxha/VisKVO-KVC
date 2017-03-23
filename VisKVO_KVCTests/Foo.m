//
//  Foo.m
//  VisKVO_KVC
//
//  Created by WzxJiang on 17/3/23.
//  Copyright © 2017年 wzxjiang. All rights reserved.
//

#import "Foo.h"

@implementation Foo

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"bar"]) {
        self.name = change[@"new"];
    }
}

@end
