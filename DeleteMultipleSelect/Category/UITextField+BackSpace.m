//
//  UITextField+BackSpace.m
//  DeleteMultipleSelect
//
//  Created by Horizon on 2021/7/21.
//

#import "UITextField+BackSpace.h"
#import <objc/runtime.h>

@implementation UITextField (BackSpace)

static const char *kDelegatePropertyKey = "kDelegatePropertyKey";
static const char *kBlockPropertyKey = "kBlockPropertyKey";

+ (void)load {
    Method originalMethod = class_getInstanceMethod([self class], NSSelectorFromString(@"deleteBackward"));
    Method targetMethod = class_getInstanceMethod([self class], @selector(mk_deleteBackward));
    method_exchangeImplementations(originalMethod, targetMethod);
}

- (id<BackSpaceDelegate>)bsDelegate {
    return objc_getAssociatedObject(self, kDelegatePropertyKey);
}

- (void)setBsDelegate:(id<BackSpaceDelegate>)bsDelegate {
    objc_setAssociatedObject(self, kDelegatePropertyKey, bsDelegate, OBJC_ASSOCIATION_ASSIGN);
}

- (void (^)(void))backSpaceCallback {
    return objc_getAssociatedObject(self, kBlockPropertyKey);
}

- (void)setBackSpaceCallback:(void (^)(void))backSpaceCallback {
    objc_setAssociatedObject(self, kBlockPropertyKey, backSpaceCallback, OBJC_ASSOCIATION_COPY);
}

- (void)mk_deleteBackward {
    [self mk_deleteBackward];
    
    if ([self.bsDelegate respondsToSelector:@selector(textFieldBackSpaceTapped:)]) {
        [self.bsDelegate textFieldBackSpaceTapped:self];
    }
}

@end
