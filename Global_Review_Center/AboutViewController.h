//
//  AboutViewController.h
//  Global_Review_Center
//
//  Created by Uri Fedorenko on 1/19/16.
//  Copyright © 2016 Oleg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *m_webView;
@property (weak, nonatomic) IBOutlet UILabel *mTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *separatView;
@property (weak, nonatomic) IBOutlet UIView *wrapperView;

@end
