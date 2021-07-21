//
//  CustomButton.m
//  DeleteMultipleSelect
//
//  Created by Horizon on 2021/7/21.
//

#import "CustomButton.h"

@implementation CustomButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    if (isSelected) {
        self.layer.borderColor = [UIColor redColor].CGColor;
        self.layer.borderWidth = 2.0;
    }
}

@end
