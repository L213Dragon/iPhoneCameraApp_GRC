//
//  CheckCaptureImageView.h
//  Global_Review_Center
//
//  Created by Admin on 1/28/16.
//  Copyright © 2016 Oleg. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CheckCaptureImageViewDelegate;

@interface CheckCaptureImageView : UIView

@property (nonatomic, weak) id<CheckCaptureImageViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *m_imgView;

@property (weak, nonatomic) IBOutlet UIButton *m_btnCancel;
- (IBAction)actionCancel:(id)sender;

@end

@protocol  CheckCaptureImageViewDelegate <NSObject>

- (void) cancelCapturedImage;
- (void) confirmCapturedImage;

@end