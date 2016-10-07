//
//  AboutViewController.m
//  Global_Review_Center
//
//  Created by Uri Fedorenko on 1/19/16.
//  Copyright © 2016 Oleg. All rights reserved.
//

#import "AboutViewController.h"
#import "YCLeftViewController.h"
#import "RESideMenu.h"

@interface AboutViewController (){
    
}

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.title = @"Global Review Center";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_icon.png"] style:UIBarButtonItemStyleDone target:self action:@selector(presentLeftMenuViewController:)];
    
    if([[UIDevice currentDevice]userInterfaceIdiom] != UIUserInterfaceIdiomPhone)
    {
        //iPad
        self.wrapperView.frame = CGRectMake(0.f, 64.f, self.view.frame.size.width, self.view.frame.size.height - 64.f);
        self.mTitleLabel.frame = CGRectMake(0.f, 0.f, self.view.frame.size.width, 50.f);
        self.mTitleLabel.font = [UIFont systemFontOfSize:25.f];
        self.separatView.frame = CGRectMake(0.f, 50.f, self.view.frame.size.width, 4.f);
        self.m_webView.frame = CGRectMake(5.f, 56.f, self.view.frame.size.width - 10.f, self.view.frame.size.height - 115.f);
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [self loadWebPage];
}

- (void) loadWebPage
{
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        NSString* strHTMLPath = [[NSBundle mainBundle] pathForResource:@"privacypolicy" ofType:@"html"];
        NSURL* urlPrivacy = [NSURL URLWithString:strHTMLPath];
        [self.m_webView loadRequest:[NSURLRequest requestWithURL:urlPrivacy]];
    }
    else
    {
        //[ipad]
        NSString* strHTMLPath = [[NSBundle mainBundle] pathForResource:@"privacypolicy_iPad" ofType:@"html"];
        NSURL* urlPrivacy = [NSURL URLWithString:strHTMLPath];
        [self.m_webView loadRequest:[NSURLRequest requestWithURL:urlPrivacy]];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
