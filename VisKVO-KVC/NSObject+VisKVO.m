

//
//  NSObject+KVO.m
//  KVO
//
//  Created by WzxJiang on 17/3/9.
//  Copyright © 2017年 wzxjiang. All rights reserved.
//

#import "NSObject+VisKVO.h"
#import "NSObject+VisKVC.h"

#import <objc/runtime.h>
#import <objc/message.h>

NSString *const kVisKVOClassPrefix = @"VisKVO_";
NSString *const kVisKVOAssociatedInfos = @"kVisKVOAssociatedInfos";


@implementation NSObject (VisKVO)

static Class _kvo_class(id self, SEL _cmd) {
    return class_getSuperclass(object_getClass(self));
}

static SEL _setterSELWithKey (NSString * key) {
    return NSSelectorFromString([NSString stringWithFormat:@"set%@:", [key capitalizedString]]);
}

static void _vis_kvo_setter (id self, SEL _cmd, id newValue) {
    NSString * setterSELName = NSStringFromSelector(_cmd);
    
    NSString * key = [[setterSELName substringWithRange:NSMakeRange(3, setterSELName.length - 4)] lowercaseString];
    
    struct objc_super superclass = {
        .receiver = self,
        .super_class = class_getSuperclass(object_getClass(self))
    };
    
    NSDictionary * currentInfo;
    NSMutableArray * infos = objc_getAssociatedObject(self, &kVisKVOAssociatedInfos);
    for (NSDictionary * info in infos) {
        if ([info[@"keyPath"] isEqualToString: key]) {
            currentInfo = info;
            break;
        }
    }
    
    void (*vis_objc_msgSendSuper)(void *, SEL, id) = (void *)objc_msgSendSuper;

    vis_objc_msgSendSuper(&superclass, NSSelectorFromString(setterSELName), newValue);

    if (!currentInfo) {
        return;
    }
    
    NSMutableDictionary * change = [NSMutableDictionary dictionary];
    
    NSUInteger options = [currentInfo[@"options"] unsignedIntegerValue];
    
    if (options & NSKeyValueObservingOptionNew) {
        [change setObject:newValue forKey:@"new"];
    }
    
    if (options & NSKeyValueObservingOptionOld) {
        [change setObject:[self vis_valueForKey:key] forKey:@"old"];
    }
    
    
    void (*vis_objc_msgSend)(id, SEL, NSString *, id, NSDictionary *, void *) = (void *)objc_msgSend;
    
    
    vis_objc_msgSend(currentInfo[@"observer"],
                     @selector(observeValueForKeyPath:ofObject:change:context:),
                     key,
                     self,
                     [change copy],
                     nil);
}

- (void)vis_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context {
    Class originClass = object_getClass(self);
    NSString * originClassName = NSStringFromClass(originClass);
    
    if (![originClassName hasPrefix:kVisKVOClassPrefix]) {
        Class kvoClass = [self _makeKVOClassWithOriginClass:originClass];
        
        object_setClass(self, kvoClass);
    }
    
    SEL setterSEL = _setterSELWithKey(keyPath);
    
    if (![self _hasSelector: setterSEL]) {
        Method setterMethod = class_getInstanceMethod(originClass, setterSEL);
        class_addMethod(object_getClass(self), setterSEL, (IMP)_vis_kvo_setter, method_getTypeEncoding(setterMethod));
        
        NSMutableArray * infos = objc_getAssociatedObject(self, &kVisKVOAssociatedInfos);
        if (!infos) {
            infos = [NSMutableArray array];
            objc_setAssociatedObject(self, &kVisKVOAssociatedInfos, infos, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        
        [infos addObject: @{
                           @"observer": observer,
                           @"keyPath": keyPath,
                           @"options": @(options)
                           }];
    }
}

- (void)vis_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {
    Class kvoClass = object_getClass(self);
    NSString * kvoClassName = NSStringFromClass(kvoClass);
    
    if (![kvoClassName hasPrefix:kVisKVOClassPrefix]) {
        return;
    }
    
    if (![self _hasSelector: _setterSELWithKey(keyPath)]) {
        return;
    }
    
    NSMutableArray * infos = objc_getAssociatedObject(self, &kVisKVOAssociatedInfos);
    for (NSDictionary * info in infos) {
        if ([info[@"keyPath"] isEqualToString: keyPath]) {
            [infos removeObject:info];
            break;
        }
    }
    
    if (infos.count == 0) {
        NSString * originClassName = [kvoClassName componentsSeparatedByString:kVisKVOClassPrefix].lastObject;
        Class originClass = NSClassFromString(originClassName);
        
        object_setClass(self, originClass);
        
        objc_disposeClassPair(kvoClass);
    }
}

- (Class)_makeKVOClassWithOriginClass:(Class)originClass {
    NSString * kvoClassName = [kVisKVOClassPrefix stringByAppendingString: NSStringFromClass(originClass)];
    Class kvoClass = NSClassFromString(kvoClassName);
    if (kvoClass) {
        return kvoClass;
    }
    
    kvoClass = objc_allocateClassPair(originClass, kvoClassName.UTF8String, 0);
    
    Method classMethod = class_getInstanceMethod(originClass, @selector(class));
    
    class_addMethod(kvoClass, @selector(class), (IMP)_kvo_class, method_getTypeEncoding(classMethod));
    
    class_addIvar(kvoClass, "observers", sizeof(NSArray *), log2(sizeof(NSArray *)), @encode(NSArray *));
    
    objc_registerClassPair(kvoClass);
    
    return kvoClass;
}

- (BOOL)_hasSelector:(SEL)selector {
    Class clazz = object_getClass(self);
    unsigned int methodCount = 0;
    Method* methodList = class_copyMethodList(clazz, &methodCount);
    for (unsigned int i = 0; i < methodCount; i++) {
        SEL thisSelector = method_getName(methodList[i]);
        if (thisSelector == selector) {
            free(methodList);
            return YES;
        }
    }
    
    free(methodList);
    return NO;
}

@end
