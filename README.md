# BackSpace
类似于键盘删除多选对象效果实现

## 背景

背景是，实现一个分享到微信，多选加输入框，点击键盘删除键，删除多选选中对象的东西。

## 实现

由于`UITextField`没有删除键的代理，所以笔者最开始的想法是，通过`textField:shouldChangeCharactersInRange:replacementString:`来实现监听，当当前字符串为空且要替换字符串为空时，说明是点击的删除按钮，通过Block方法回掉出去，代码如下：

``` Objective-C

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ((textField.text.length == 0) && (string.length == 0)) {
        if (self.deleteBackwardBlock) {
            self.deleteBackwardBlock
        }
    }
    return YES;
}

```


验证后发现：第三方输入法用此逻辑没有问题，但是系统原生输入法，当textField为空时，点击删除键是不会走这个代理方法的，故而此方法行不通。


然后，笔者就查了一下，可以通过runtime，来获取到`deleteBackward`事件，通过hook此事件，可以获取到点击键盘删除按钮的事件，代码如下：

``` Objective-C

//  UITextField+BackSpace.h
#import <UIKit/UIKit.h>

@protocol BackSpaceDelegate <NSObject>

@optional
- (void)textFieldBackSpaceTapped:(UITextField *)textField;

@end

@interface UITextField (BackSpace)

@property (nonatomic, weak) id<BackSpaceDelegate>bsDelegate;
@property (nonatomic, copy) void(^ backSpaceCallback)(void);

@end



//  UITextField+BackSpace.m

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

```

然后在要使用的地方设置textField.bsdelegate，并实现textFieldBackSpaceTapped:方法。测试后可以发现点击键盘删除键时，代理方法确实响应了，代码如下：

``` Objective-C

@interface TargetView ()<BackSpaceDelegate>

@property (nonatomic, strong) UITextField *textField;

@end

@implementation TargetView

...
    self.textField.delegate = self;
    self.textField.bsDelegate = self;
...

- (void)textFieldBackSpaceTapped:(UITextField *)textField {
    NSLog(@"删除");
}


@end

```

再回过头来看需求，当输入框中没有数据时，删除多选选中结果。所以笔者直接在此代理方法中判断，当textField的text为空时，删除多选选中结果。

代码如下：

``` Objective-C

- (void)textFieldBackSpaceTapped:(UITextField *)textField {
    NSLog(@"删除");
    
    if (textField.text.length != 0) {
        return;
    }
    
    UIView *lastView = self.multipleSelectView.subviews.lastObject;
    if (lastView) {
        [lastView removeFromSuperview];
    }
}

```

调试后发现，当到最后一个字符时，点击删除，字符和多选一同被删除了，而我们需要的时，在最后一个字符删除后，再次点击删除才应该操作多选。

笔者最初的理解应该是，删除按钮的事件在前面，点击删除按钮时，获取到的textField的text应该是未删除的，然后再走`textField:shouldChangeCharactersInRange:replacementString:`方法。然而调试后发现，实际的顺序是点击删除按钮，然后执行了`textField:shouldChangeCharactersInRange:replacementString:`，最后才走到了`textFieldBackSpaceTapped:`的回掉。

所以就出现了上面的情况，那怎么解决呢？

最简单的方法是记录一下上一次输入框的值，当上一次输入框的值为空时，才可以删除多选数据；否则不操作多选的数据，只更新上一次输入框的值。

代码如下：

``` Objective-C

- (void)textFieldBackSpaceTapped:(UITextField *)textField {
    NSLog(@"删除");
    
    if (textField.text.length != 0) {
        self.previousStr = textField.text;
        return;
    }
    
    if (self.previousStr.length != 0) {
        self.previousStr = textField.text;
        return;
    }
    
    UIView *lastView = self.multipleSelectView.subviews.lastObject;
    if (lastView) {
        [lastView removeFromSuperview];
    }
}

```

效果如下：

![screen-recording-2021-07-21-at-17.52.05.gif](https://inews.gtimg.com/newsapp_ls/0/13793360545/0.gif)


代码参考：
[BackSpace](https://github.com/mokong/BackSpace)
