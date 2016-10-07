//
//  YCLeftViewController.m
//  YCW
//
//  Created by apple on 15/12/17.
//  Copyright (c) 2015 apple. All rights reserved.
//

#import "YCLeftViewController.h"
#import "RESideMenu.h"
#import "WriteViewController.h"
#import "AboutViewController.h"
#import "TermsViewController.h"

/*
#import "YCSettingViewController.h"
#import "YCFeedbackViewController.h"
#import "YCServiceViewController.h"
#import "YCAboutViewController.h"
*/
#import "AboutViewController.h"
#import "WriteViewController.h"
#import "TermsViewController.h"

@interface YCLeftViewController ()

@property (nonatomic, assign) NSInteger previousRow;

@end

@implementation YCLeftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if([[UIDevice currentDevice]userInterfaceIdiom] != UIUserInterfaceIdiomPhone)
    {
        self.aboutLabel.font = [UIFont systemFontOfSize:20.f];
        self.writeLabel.font = [UIFont systemFontOfSize:20.f];
        self.termsLabel.font = [UIFont systemFontOfSize:20.f];
        self.aboutView.frame = CGRectMake(0.f, 64.f, self.aboutView.frame.size.width, 50.f);
        self.writeView.frame = CGRectMake(0.f, 114.f, self.writeView.frame.size.width, 50.f);
        self.termsView.frame = CGRectMake(0.f, 164.f, self.termsView.frame.size.width, 50.f);
        self.firstSepView.frame = CGRectMake(0.f, 0.f, self.aboutView.frame.size.width, 1.f);
        self.secondSepView.frame = CGRectMake(0.f, 49.f, self.aboutView.frame.size.width, 1.f);
        self.thirdSepView.frame = CGRectMake(0.f, 49.f, self.aboutView.frame.size.width, 1.f);
        self.firthSepView.frame = CGRectMake(0.f, 49.f, self.aboutView.frame.size.width, 1.f);
    }

}


//
- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)actionWriteReview:(id)sender {
    [self gotoViewCon:0];
}

- (IBAction)actionAbout:(id)sender {
    [self gotoViewCon:1];
}

- (IBAction)actionTOS:(id)sender {
    [self gotoViewCon:2];
}

- (void) gotoViewCon:(int) nIdx
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UIViewController *center;
    if (nIdx == 0) {
        center = self.sideMenuViewController.mainController;
    }else if(nIdx == 2){
        AboutViewController* viewCon = [storyboard instantiateViewControllerWithIdentifier:@"aboutview"];
        center = [[UINavigationController alloc] initWithRootViewController:viewCon];
    }else if (nIdx== 1){
        TermsViewController* viewCon = [storyboard instantiateViewControllerWithIdentifier:@"termsview"];
        center = [[UINavigationController alloc] initWithRootViewController:viewCon];
    }
    
    [self.sideMenuViewController setContentViewController:center
                                                 animated:YES];
    [self.sideMenuViewController hideMenuViewController];
    
    self.previousRow = nIdx;
}

@end
