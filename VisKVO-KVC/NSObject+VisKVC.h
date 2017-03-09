//
//  NSObject+VisKVC.h
//  KVO
//
//  Created by WzxJiang on 17/3/9.
//  Copyright © 2017年 wzxjiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (VisKVC)

- (void)vis_setValue:(id)value forKey:(NSString *)key;

- (id)vis_valueForKey:(NSString *)key;

@end
