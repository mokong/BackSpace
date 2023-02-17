//
//  ViewController.m
//  DeleteMultipleSelect
//
//  Created by MorganWang  on 2021/7/21.
//

#import "ViewController.h"
#import "UITextField+BackSpace.h"
#import "CustomButton.h"

@interface ViewController ()<UITextFieldDelegate, BackSpaceDelegate>

@property (weak, nonatomic) IBOutlet UIView *multipleSelectView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic, strong) NSString *previousStr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupMultiSelectSubviews];
    self.textField.delegate = self;
    self.textField.bsDelegate = self;

    self.previousStr = @"";
//    self.textField.backSpaceCallback = ^{
//
//    };
    
}

- (void)setupMultiSelectSubviews {
    [self.multipleSelectView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSInteger count = 5;
    CGFloat leftSpace = 0.0;
    CGFloat topSpace = 0.0;
    
    CGFloat totalWidth = [UIScreen mainScreen].bounds.size.width - 51.0 * 2.0 - 4.0;
    CGFloat width = totalWidth / count;
    CGFloat height = 64.0;
    for (int i = 0; i < count; i++) {
        CustomButton *tempBtn = [CustomButton buttonWithType:UIButtonTypeCustom];
        tempBtn.frame = CGRectMake(leftSpace, topSpace, width, height);
        tempBtn.backgroundColor = [UIColor systemYellowColor];
        [tempBtn setTitle:[NSString stringWithFormat:@"%d", i] forState:UIControlStateNormal];
        [tempBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.multipleSelectView addSubview:tempBtn];
        
        leftSpace += width+1.0;
    }
}

#pragma mark - delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

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
        if ([lastView isKindOfClass:[CustomButton class]]) {
            CustomButton *btn = (CustomButton *)lastView;
            if (btn.isSelected == YES) {
                [lastView removeFromSuperview];
            }
            else {
                btn.isSelected = YES;
            }
        }
    }
}

#pragma mark - action
- (IBAction)resetMultiSelectSubviews:(id)sender {
    [self setupMultiSelectSubviews];
}


@end
