//
//  ReviewTextView.m
//  Global_Review_Center
//
//  Created by Admin on 1/28/16.
//  Copyright © 2016 Oleg. All rights reserved.
//

#import "ReviewTextView.h"

#define PLACEHOLDER_TEXT            @"Please write something..."

@implementation ReviewTextView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (void) awakeFromNib
{
    self.m_txtView.delegate = self;
    self.m_txtView.text = PLACEHOLDER_TEXT;
    self.m_txtView.textColor = [UIColor lightGrayColor];
    
    [self makeCornerRadiusControl:self.m_txtView radius:8.f backgroundcolor:[UIColor whiteColor] borderColor:[UIColor darkGrayColor] borderWidth:1.f];
}

- (void) makeCornerRadiusControl:(UIView *) targetView radius:(float) fRadius backgroundcolor:(UIColor *) bgColor borderColor:(UIColor *) borderColor borderWidth:(float) fBorderWidth
{
    targetView.backgroundColor = bgColor;
    targetView.layer.cornerRadius = fRadius;
    targetView.layer.borderColor = borderColor.CGColor;
    targetView.layer.borderWidth = fBorderWidth;
    targetView.clipsToBounds = YES;
    
}

- (void) hideTextViewKeyboard
{
    [self.m_txtView resignFirstResponder];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:PLACEHOLDER_TEXT]) {
        textView.text = @"";
        textView.textColor = [UIColor darkGrayColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = PLACEHOLDER_TEXT;
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}

@end
