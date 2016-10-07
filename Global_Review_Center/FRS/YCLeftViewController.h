//
//  YCLeftViewController.h
//  YCW
//
//  Created by apple on 15/12/17.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YCLeftViewController : UIViewController

- (IBAction)actionWriteReview:(id)sender;
- (IBAction)actionAbout:(id)sender;
- (IBAction)actionTOS:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *firstSepView;
@property (weak, nonatomic) IBOutlet UIView *secondSepView;
@property (weak, nonatomic) IBOutlet UIView *thirdSepView;
@property (weak, nonatomic) IBOutlet UIView *aboutView;
@property (weak, nonatomic) IBOutlet UIView *writeView;
@property (weak, nonatomic) IBOutlet UIView *termsView;
@property (weak, nonatomic) IBOutlet UILabel *aboutLabel;
@property (weak, nonatomic) IBOutlet UILabel *writeLabel;
@property (weak, nonatomic) IBOutlet UILabel *termsLabel;
@property (weak, nonatomic) IBOutlet UIView *firthSepView;
@property (strong, nonatomic) IBOutlet UIView *wrapperView;

@end
