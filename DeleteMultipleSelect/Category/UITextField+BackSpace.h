//
//  UITextField+BackSpace.h
//  DeleteMultipleSelect
//
//  Created by Horizon on 2021/7/21.
//

#import <UIKit/UIKit.h>

@protocol BackSpaceDelegate <NSObject>

@optional
- (void)textFieldBackSpaceTapped:(UITextField *)textField;

@end

@interface UITextField (BackSpace)

@property (nonatomic, weak) id<BackSpaceDelegate>bsDelegate;
@property (nonatomic, copy) void(^ backSpaceCallback)(void);

@end

