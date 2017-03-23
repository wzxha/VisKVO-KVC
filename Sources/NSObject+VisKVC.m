

//
//  NSObject+VisKVC.m
//  KVO
//
//  Created by WzxJiang on 17/3/9.
//  Copyright © 2017年 wzxjiang. All rights reserved.
//

#import "NSObject+VisKVC.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation NSObject (VisKVC)

- (id)vis_valueForKey:(NSString *)key {
    id value = nil;
    
    SEL sel = [self _selectorWithName:key];
    
    if (!sel) {
        return nil;
    }
    
    id (*vis_objc_msgSend)(id, SEL) = (void *)objc_msgSend;
    
    value = vis_objc_msgSend(self, sel);
    
    return value;
}

- (void)vis_setValue:(id)value forKey:(NSString *)key {
    key = [NSString stringWithFormat:@"set%@:", [key capitalizedString]];
    
    SEL sel = [self _selectorWithName:key];
    
    if (!sel) {
        return;
    }
    
    void (*vis_objc_msgSend)(id, SEL, id) = (void *)objc_msgSend;
    
    vis_objc_msgSend(self, sel, value);
}

- (SEL)_selectorWithName:(NSString *)name {
    Class clazz = [self class];

    unsigned int methodCount = 0;
    
    Method *methodList = class_copyMethodList(clazz, &methodCount);
    for (unsigned int i = 0; i < methodCount; i++) {
        Method m = methodList[i];
        SEL sel = method_getName(m);
        if ([NSStringFromSelector(sel) isEqualToString:name]) {
            free(methodList);
            return sel;
        }
    }
    
    free(methodList);
    return nil;
}


@end
