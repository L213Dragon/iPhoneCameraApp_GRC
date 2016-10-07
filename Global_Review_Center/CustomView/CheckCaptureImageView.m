//
//  CheckCaptureImageView.m
//  Global_Review_Center
//
//  Created by Admin on 1/28/16.
//  Copyright © 2016 Oleg. All rights reserved.
//

#import "CheckCaptureImageView.h"
#import "FAKFontAwesome.h"

@implementation CheckCaptureImageView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (void) awakeFromNib
{
    float fIconSize = 32.f;
    FAKFontAwesome *cancelIcon = [FAKFontAwesome timesCircleIconWithSize:fIconSize];
    [cancelIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *imgCancel = [cancelIcon imageWithSize:CGSizeMake(fIconSize, fIconSize)];
    [self.m_btnCancel setImage:imgCancel forState:UIControlStateNormal];
    
    
}

- (IBAction)actionCancel:(id)sender {
    if (self.delegate || [self.delegate respondsToSelector:@selector(cancelCapturedImage)])
        [self.delegate cancelCapturedImage];
}


@end
