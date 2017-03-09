

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

static SEL _setterSELWithKey (NSString * key) {
    return NSSelectorFromString([NSString stringWithFormat:@"set%@:", [key capitalizedString]]);
}

- (id)vis_valueForKey:(NSString *)key {
    key = [@"_" stringByAppendingString:key];
    
    Class clazz = [self class];
    
    id value = nil;
    
    unsigned int ivarCount = 0;
    
    Ivar * ivarList = class_copyIvarList(clazz, &ivarCount);
    
    for (unsigned int i = 0; i < ivarCount; i++) {
        Ivar v = ivarList[i];
        
        NSString * name = [NSString stringWithCString:ivar_getName(v) encoding: NSUTF8StringEncoding];
        
        if ([key isEqualToString:name]) {
            value = object_getIvar(self, v);
            break;
        }
    }
    
    free(ivarList);
    
    return value;
}

- (void)vis_setValue:(id)value forKey:(NSString *)key {
    NSString * newKey = [@"_" stringByAppendingString:key];
    
    Class clazz = [self class];
    
    unsigned int ivarCount = 0;
    
    Ivar * ivarList = class_copyIvarList(clazz, &ivarCount);
    
    for (unsigned int i = 0; i < ivarCount; i++) {
        Ivar v = ivarList[i];
        
        NSString * name = [NSString stringWithCString:ivar_getName(v) encoding: NSUTF8StringEncoding];
        
        if ([newKey isEqualToString:name]) {
            
//            object_setIvar(self, v, value); kvc会走kvo，所以应该用set方法
            void (*vis_objc_msgSend)(id, SEL, id) = (void *)objc_msgSend;
            
            vis_objc_msgSend(self,_setterSELWithKey(key), value);
            
            break;
        }
    }
    
    free(ivarList);
}


@end
