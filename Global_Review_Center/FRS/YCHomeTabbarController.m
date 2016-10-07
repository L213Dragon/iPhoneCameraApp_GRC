//
//  YCFirstViewController.m
//  Left
//
//  Created by apple on 15/12/15.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "YCHomeTabbarController.h"
/*
#import "YCOneViewController.h"
#import "YCThreeViewController.h"
#import "YCFiveViewController.h"
#import "YCTwoViewController.h"
#import "YCFourViewController.h"
*/

@interface YCHomeTabbarController ()<UITabBarControllerDelegate>

@property(nonatomic, strong) UIButton *openDrawerButton;
@end

@implementation YCHomeTabbarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.selectedIndex = 0;
   
  
    // 1.初始化子控制器
    /*YCOneViewController *myOne = [[YCOneViewController alloc] init];
    [self addChildVc:myOne title:@"one" image:@"one_icon" selectedImage:@"one_icon"];
    
    YCTwoViewController *myTwo = [[YCTwoViewController alloc] init];
    [self addChildVc:myTwo title:@"two" image:@"Two_icon" selectedImage:@"lTwo_icon"];
    
    YCThreeViewController *myThree = [[YCThreeViewController alloc] init];
    [self addChildVc:myThree title:@"three" image:@"Three_icon" selectedImage:@"Three_icon"];
    
    YCFourViewController *myFour = [[YCFourViewController alloc] init];
    [self addChildVc:myFour title:@"four" image:@"four_icon" selectedImage:@"four_icon"];
    
    YCFiveViewController *myFive = [[YCFiveViewController alloc] init];
    [self addChildVc:myFive title:@"five" image:@"five_icon" selectedImage:@"five_icon"];*/
    
    
    
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.selectedIndex = self.selectVCIndex;
}

/**
 *  添加一个子控制器
 *
 *  @param childVc       子控制器
 *  @param title         标题
 *  @param image         图片
 *  @param selectedImage 选中的图片
 */
- (void)addChildVc:(UIViewController *)childVc title:(NSString *)title image:(NSString *)image selectedImage:(NSString *)selectedImage
{
    childVc.title = title;
    childVc.tabBarItem.image = [UIImage imageNamed:image];
    childVc.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
   
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = [UIColor greenColor];
    NSMutableDictionary *selectTextAttrs = [NSMutableDictionary dictionary];
    selectTextAttrs[NSForegroundColorAttributeName] = [UIColor purpleColor];
    [childVc.tabBarItem setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
    [childVc.tabBarItem setTitleTextAttributes:selectTextAttrs forState:UIControlStateSelected];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:childVc];
    [self addChildViewController:nav];
}


#pragma mark - Configuring the view’s layout behavior

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com