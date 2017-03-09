//
//  NSObject+KVO.h
//  KVO
//
//  Created by WzxJiang on 17/3/9.
//  Copyright © 2017年 wzxjiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (VisKVO)

- (void)vis_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context;

- (void)vis_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;

@end
