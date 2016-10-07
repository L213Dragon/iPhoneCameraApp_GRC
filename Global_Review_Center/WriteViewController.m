//
//  WriteViewController.m
//  Global_Review_Center
//
//  Created by Oleg Fedorenko on 1/19/16.
//  Copyright © 2016 Oleg. All rights reserved.
//

#import "WriteViewController.h"
#import "YCLeftViewController.h"
#import "RESideMenu.h"
#import "DXStarRatingView.h"
#import <UIKit/UILabel.h>
#import <UIKit/UIButton.h>
#import "NSString+emailValidation.h"

#define MARGIN_CONTROLS                          90.f
#define MARGIN_CANVAS                            20.f
#define DEFAULT_SCROLLVIEW_CONTENT_HEIGHT        500.f

//#define MARGIN_CONTROLS_iPad                            200.f
#define MARGIN_CANVAS_iPad                              100.f
#define DEFAULT_SCROLLVIEW_CONTENT_HEIGHT_iPad          800.f

@interface WriteViewController () <CustomCameraViewDelegate, RecordAudioViewDelegate>
{
    
    int iBtnPhotoOriginX;
    int iBtnPhotoOriginY;
    
    int iBtnAddPhotoOriginX;
    int iBtnAddPhotoOriginY;
    
    int iPhotoViewOriginX;
    int iPhotoViewOriginY;
    
    int imViewOriginX;
    int imViewOriginY;
    
    int imBottonmenuX;
    int imBottonmenuY;
    
    NSNumber *rating;
    bool isAcceptTerms;
    bool currentDeviceisiPhone;
}

@property (weak, nonatomic) IBOutlet DXStarRatingView *starRatingView;

@end

@implementation WriteViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    eCurrentMediaType = NONE_MEDIA;
    bAlreadyPhotoMedia = false;
    bAlreadyAudioMedia = false;
    bAlreadyTextMedia = false;
    bAlreadyVideoMedia = false;
    
    [self initAllMediaValues];
    [self makeSelectedStatusForMedia];
    
    self.spinner.hidden = YES;
    
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        scheduleType = 0; // schedule type is not defined
        currentDeviceisiPhone = true;
        // init all element position on iPhone
        fScrollViewContentHeight = DEFAULT_SCROLLVIEW_CONTENT_HEIGHT;//init scroll view content height as 500.
        fCameraCanvasViewWidth = CGRectGetWidth(self.view.frame) - MARGIN_CANVAS * 2;
        self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fScrollViewContentHeight);
        self.mphotoView.frame = CGRectMake(iPhotoViewOriginX, iPhotoViewOriginY, fCameraCanvasViewWidth, 0.f);
        self.mView.frame = CGRectMake(imViewOriginX, imViewOriginY, fCameraCanvasViewWidth, 0.f);
        self.viewChooseMedia.frame = CGRectMake(self.viewChooseMedia.frame.origin.x, self.viewChooseMedia.frame.origin.y, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.viewChooseMedia.frame));
        self.m_viewBottomMenu.frame = CGRectMake(0, fScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.m_viewBottomMenu.frame));
        fOriginMenuViewPosY = self.viewChooseMedia.frame.origin.y;
        
        // init background color for mView and mPhotoView
        self.mView.backgroundColor = [UIColor blackColor];
        self.mphotoView.backgroundColor = [UIColor blackColor];
        
        // Do any additional setup after loading the view.
        self.navigationItem.title = @"Global Review Center";
        self.view.backgroundColor = [UIColor whiteColor];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_icon.png"] style:UIBarButtonItemStyleDone target:self action:@selector(presentLeftMenuViewController:)];
        
        [self.chkBtn setImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateSelected];
        [self.chkBtn setImage:[UIImage imageNamed:@"uncheck.png"] forState:UIControlStateNormal];
        
        
        //Add star rating
        [self.starRatingView setStars:5 callbackBlock:^(NSNumber *newRating) {
            NSLog(@"didChangeRating: %@",newRating);
            rating = newRating;
        }];
        
        //scrollview setting
        self.mScrollView.scrollEnabled = YES;
        self.mScrollView.delegate = self;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
        
        tapGesture.cancelsTouchesInView = NO;
        
        [self.mScrollView addGestureRecognizer:tapGesture];
        
        self.mScrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        
        [self makeCornerRadiusControl:self.btnVideo radius:6.f backgroundcolor:[UIColor clearColor] borderColor:[UIColor lightGrayColor] borderWidth:2.f];
        [self makeCornerRadiusControl:self.btnAudio radius:6.f backgroundcolor:[UIColor clearColor] borderColor:[UIColor lightGrayColor] borderWidth:2.f];
        [self makeCornerRadiusControl:self.btnText radius:6.f backgroundcolor:[UIColor clearColor] borderColor:[UIColor lightGrayColor] borderWidth:2.f];
        
        [self makeCornerRadiusControl:self.btnPhoto radius:6.f backgroundcolor:[UIColor clearColor] borderColor:[UIColor darkGrayColor] borderWidth:2.f];
        [self makeCornerRadiusControl:self.btnAddPhoto radius:6.f backgroundcolor:[UIColor clearColor] borderColor:[UIColor lightGrayColor] borderWidth:2.f];
        [self makeCornerRadiusControl:self.btnSubmit radius:6.f backgroundcolor:[UIColor colorWithRed:42.f / 255.f green:68.f / 255.f blue:90.f / 255.f alpha:2.f] borderColor:[UIColor darkGrayColor] borderWidth:0.f];
        
        
        //init checkbox value as false
        isAcceptTerms = false;
        //Hide two photo button
        self.btnAddPhoto.hidden = YES;
        self.btnPhoto.hidden = YES;
        
        // Get Origin X, Y of two photo button and mView and photoview
        iBtnAddPhotoOriginX = self.btnAddPhoto.frame.origin.x;
        iBtnAddPhotoOriginY = self.btnAddPhoto.frame.origin.y;
        iBtnPhotoOriginX = self.btnPhoto.frame.origin.x;
        iBtnPhotoOriginY = self.btnPhoto.frame.origin.y;
        iPhotoViewOriginX = self.mphotoView.frame.origin.x;
        iPhotoViewOriginY = self.mphotoView.frame.origin.y;
        imViewOriginX = self.mView.frame.origin.x;
        imViewOriginY = self.mView.frame.origin.y;
        imBottonmenuX = self.m_viewBottomMenu.frame.origin.x;
        imBottonmenuY = self.m_viewBottomMenu.frame.origin.y;
        
    }
    
    else if (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && ([UIScreen mainScreen].bounds.size.height == 1366 || [UIScreen mainScreen].bounds.size.width == 1366))) {
        //iPad Pro
        
        currentDeviceisiPhone = false;
        
        // init all element position on iPad
        
        fScrollViewContentHeight = DEFAULT_SCROLLVIEW_CONTENT_HEIGHT_iPad + 342;//init scroll view content height as 500.
        fCameraCanvasViewWidth = 568.f;
        self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fScrollViewContentHeight);
        
        //positions and size
        self.mtitleLabel.frame = CGRectMake(0.f, 64.f,  self.view.frame.size.width, 50.f);
        self.mtitleLabel.font = [UIFont systemFontOfSize:25.f];
        self.mseparatView.frame = CGRectMake(0.f, 114, self.view.frame.size.width, 4.f);
        
        self.mScrollView.frame = CGRectMake(0.f, 120.f, self.view.frame.size.width, self.mScrollView.frame.size.height);
        
        self.personalInf_L.frame = CGRectMake(178.f, 70.f, 500.f, 30);
        self.personalInf_L.font = [UIFont systemFontOfSize:25];
        self.firstname_T.frame = CGRectMake(178.f, 140.f, 220.f, 45.f);
        self.firstname_T.font = [UIFont systemFontOfSize:20.0f];
        self.lastname_T.frame = CGRectMake(402.f, 140.f, 220.f, 45.f);
        self.lastname_T.font = [UIFont systemFontOfSize:20.0f];
        self.mailadr_T.frame = CGRectMake(638.f, 140.f, 208.f, 45.f);
        self.mailadr_T.font = [UIFont systemFontOfSize:20.0f];
        
        self.compInf_L.frame = CGRectMake(178.f, 230.f, 500.f, 30.f);
        self.compInf_L.font = [UIFont systemFontOfSize:25];
        self.compname_T.frame = CGRectMake(178.f, 300.f, 668.f, 45.f);
        self.compname_T.font = [UIFont systemFontOfSize:20.0f];
        self.compcity_T.frame = CGRectMake(178.f, 400.f, 310.f, 45.f);
        self.compcity_T.font = [UIFont systemFontOfSize:20.0f];
        self.compstate_T.frame = CGRectMake(536.f, 400.f, 310.f, 45.f);
        self.compstate_T.font = [UIFont systemFontOfSize:20.0f];
        
        self.viewChooseMedia.frame = CGRectMake(178.f, 550.f, 668.f, 70.f);
        self.btnVideo.frame = CGRectMake(20.f, 10.f, 200.f, 60.f);
        self.btnVideo.titleLabel.font = [UIFont systemFontOfSize:30.0];
        self.btnAudio.frame = CGRectMake(240.f, 10.f, 200.f, 60.f);
        self.btnAudio.titleLabel.font = [UIFont systemFontOfSize:30.0];
        self.btnText.frame = CGRectMake(460.f, 10.f, 200.f, 60.f);
        self.btnText.titleLabel.font = [UIFont systemFontOfSize:30.0];
        
        self.starRatingView.frame = CGRectMake(self.starRatingView.frame.origin.x, 750.f, self.starRatingView.frame.size.width, 46.f);
        
        self.btnPhoto.frame = CGRectMake(278.f, 860.f, 468.f, 40.f);
        self.btnPhoto.titleLabel.font = [UIFont boldSystemFontOfSize:25.f];
        self.btnAddPhoto.frame = CGRectMake(328.f, 910.f, 368.f, 40.f);
        self.btnAddPhoto.titleLabel.font = [UIFont boldSystemFontOfSize:20.f];
        self.m_viewBottomMenu.frame = CGRectMake(178.f, DEFAULT_SCROLLVIEW_CONTENT_HEIGHT_iPad - self.m_viewBottomMenu.frame.size.height + 342.f, 668.f, self.m_viewBottomMenu.frame.size.height);
        //self.m_viewBottomMenu.frame = CGRectMake(0, fScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.m_viewBottomMenu.frame));
        self.chkBtn.frame = CGRectMake(50.f, 30.f, 40.f, 40.f);
        self.noticeLabel.frame = CGRectMake(80.f, 0.f, 550.f, 50.f);
        self.noticeLabel.font = [UIFont systemFontOfSize:20];
        self.btnSubmit.frame = CGRectMake(150.f, 70.f, 368.f, 55.f);
        self.btnSubmit.titleLabel.font = [UIFont systemFontOfSize:30.f];
        self.mView.frame = CGRectMake(328.f, 558.f, 568.f, 0.f);
        self.mphotoView.frame = CGRectMake(328.f, 660.f, 568.f, 0.f);
        
        
        fOriginMenuViewPosY = self.viewChooseMedia.frame.origin.y;
        
        // init background color for mView and mPhotoView
        self.mView.backgroundColor = [UIColor blackColor];
        self.mphotoView.backgroundColor = [UIColor blackColor];
        
        // Do any additional setup after loading the view.
        self.navigationItem.title = @"Global Review Center";
        self.view.backgroundColor = [UIColor whiteColor];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_icon.png"] style:UIBarButtonItemStyleDone target:self action:@selector(presentLeftMenuViewController:)];
        
        [self.chkBtn setImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateSelected];
        [self.chkBtn setImage:[UIImage imageNamed:@"uncheck.png"] forState:UIControlStateNormal];
        
        
        //Add star rating
        [self.starRatingView setStars:5 callbackBlock:^(NSNumber *newRating) {
            NSLog(@"didChangeRating: %@",newRating);
            rating = newRating;
        }];
        
        //scrollview setting
        self.mScrollView.scrollEnabled = YES;
        self.mScrollView.delegate = self;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
        
        tapGesture.cancelsTouchesInView = NO;
        
        [self.mScrollView addGestureRecognizer:tapGesture];
        
        self.mScrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        
        [self makeCornerRadiusControl:self.btnVideo radius:6.f backgroundcolor:[UIColor clearColor] borderColor:[UIColor lightGrayColor] borderWidth:2.f];
        [self makeCornerRadiusControl:self.btnAudio radius:6.f backgroundcolor:[UIColor clearColor] borderColor:[UIColor lightGrayColor] borderWidth:2.f];
        [self makeCornerRadiusControl:self.btnText radius:6.f backgroundcolor:[UIColor clearColor] borderColor:[UIColor lightGrayColor] borderWidth:2.f];
        
        [self makeCornerRadiusControl:self.btnPhoto radius:6.f backgroundcolor:[UIColor clearColor] borderColor:[UIColor darkGrayColor] borderWidth:2.f];
        [self makeCornerRadiusControl:self.btnAddPhoto radius:6.f backgroundcolor:[UIColor clearColor] borderColor:[UIColor lightGrayColor] borderWidth:2.f];
        [self makeCornerRadiusControl:self.btnSubmit radius:6.f backgroundcolor:[UIColor colorWithRed:42.f / 255.f green:68.f / 255.f blue:90.f / 255.f alpha:2.f] borderColor:[UIColor darkGrayColor] borderWidth:0.f];
        
        
        //init checkbox value as false
        isAcceptTerms = false;
        //Hide two photo button
        self.btnAddPhoto.hidden = YES;
        self.btnPhoto.hidden = YES;
        
        // Get Origin X, Y of two photo button and mView and photoview
        iBtnAddPhotoOriginX = self.btnAddPhoto.frame.origin.x;
        iBtnAddPhotoOriginY = self.btnAddPhoto.frame.origin.y;
        iBtnPhotoOriginX = self.btnPhoto.frame.origin.x;
        iBtnPhotoOriginY = self.btnPhoto.frame.origin.y;
        iPhotoViewOriginX = self.mphotoView.frame.origin.x;
        iPhotoViewOriginY = self.mphotoView.frame.origin.y;
        imViewOriginX = self.mView.frame.origin.x;
        imViewOriginY = self.mView.frame.origin.y;
        imBottonmenuX = self.m_viewBottomMenu.frame.origin.x;
        imBottonmenuY = self.m_viewBottomMenu.frame.origin.y;
        
    }
    else
    {
        currentDeviceisiPhone = false;
        
        // init all element position on iPad
        
        fScrollViewContentHeight = DEFAULT_SCROLLVIEW_CONTENT_HEIGHT_iPad;//init scroll view content height as 500.
        fCameraCanvasViewWidth = 568.f;
        self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fScrollViewContentHeight);
        
        //positions and size
        self.mScrollView.frame = CGRectMake(0.f, 120.f, self.view.frame.size.width, self.mScrollView.frame.size.height);
        self.mtitleLabel.frame = CGRectMake(0.f, 64.f,  self.view.frame.size.width, 50.f);
        self.mtitleLabel.font = [UIFont systemFontOfSize:25.f];
        self.mseparatView.frame = CGRectMake(0.f, 114, self.view.frame.size.width, 4.f);
        self.personalInf_L.frame = CGRectMake(50.f, 40.f, 500.f, 30);
        self.personalInf_L.font = [UIFont systemFontOfSize:25];
        self.firstname_T.frame = CGRectMake(50.f, 90.f, 220.f, 45.f);
        self.firstname_T.font = [UIFont systemFontOfSize:20.0f];
        self.lastname_T.frame = CGRectMake(280.f, 90.f, 220.f, 45.f);
        self.lastname_T.font = [UIFont systemFontOfSize:20.0f];
        self.mailadr_T.frame = CGRectMake(510.f, 90.f, 208.f, 45.f);
        self.mailadr_T.font = [UIFont systemFontOfSize:20.0f];
        
        self.compInf_L.frame = CGRectMake(50.f, 170.f, 500.f, 30.f);
        self.compInf_L.font = [UIFont systemFontOfSize:25];
        self.compname_T.frame = CGRectMake(50.f, 225.f, 668.f, 45.f);
        self.compname_T.font = [UIFont systemFontOfSize:20.0f];
        self.compcity_T.frame = CGRectMake(50.f, 300.f, 310.f, 45.f);
        self.compcity_T.font = [UIFont systemFontOfSize:20.0f];
        self.compstate_T.frame = CGRectMake(408.f, 300.f, 310.f, 45.f);
        self.compstate_T.font = [UIFont systemFontOfSize:20.0f];
        
        self.viewChooseMedia.frame = CGRectMake(50.f, 400.f, 668.f, 70.f);
        self.btnVideo.frame = CGRectMake(20.f, 10.f, 200.f, 60.f);
        self.btnVideo.titleLabel.font = [UIFont systemFontOfSize:30.0];
        self.btnAudio.frame = CGRectMake(240.f, 10.f, 200.f, 60.f);
        self.btnAudio.titleLabel.font = [UIFont systemFontOfSize:30.0];
        self.btnText.frame = CGRectMake(460.f, 10.f, 200.f, 60.f);
        self.btnText.titleLabel.font = [UIFont systemFontOfSize:30.0];
        
        self.starRatingView.frame = CGRectMake(self.starRatingView.frame.origin.x, 500.f, self.starRatingView.frame.size.width, 46.f);
        
        self.btnPhoto.frame = CGRectMake(150.f, 560.f, 468.f, 40.f);
        self.btnPhoto.titleLabel.font = [UIFont boldSystemFontOfSize:25.f];
        self.btnAddPhoto.frame = CGRectMake(200.f, 610.f, 368.f, 40.f);
        self.btnAddPhoto.titleLabel.font = [UIFont boldSystemFontOfSize:20.f];
        self.m_viewBottomMenu.frame = CGRectMake(50.f, DEFAULT_SCROLLVIEW_CONTENT_HEIGHT_iPad - self.m_viewBottomMenu.frame.size.height, 668.f, self.m_viewBottomMenu.frame.size.height);
        //self.m_viewBottomMenu.frame = CGRectMake(0, fScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.m_viewBottomMenu.frame));
        self.chkBtn.frame = CGRectMake(50.f, 30.f, 40.f, 40.f);
        self.noticeLabel.frame = CGRectMake(80.f, 0.f, 550.f, 50.f);
        self.noticeLabel.font = [UIFont systemFontOfSize:20];
        self.btnSubmit.frame = CGRectMake(150.f, 70.f, 368.f, 55.f);
        self.btnSubmit.titleLabel.font = [UIFont systemFontOfSize:30.f];
        self.mView.frame = CGRectMake(100.f, 558.f, 568.f, 0.f);
        self.mphotoView.frame = CGRectMake(100.f, 660.f, 568.f, 0.f);
        
        
        fOriginMenuViewPosY = self.viewChooseMedia.frame.origin.y;
        
        // init background color for mView and mPhotoView
        self.mView.backgroundColor = [UIColor blackColor];
        self.mphotoView.backgroundColor = [UIColor blackColor];
        
        // Do any additional setup after loading the view.
        self.navigationItem.title = @"Global Review Center";
        self.view.backgroundColor = [UIColor whiteColor];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_icon.png"] style:UIBarButtonItemStyleDone target:self action:@selector(presentLeftMenuViewController:)];
        
        [self.chkBtn setImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateSelected];
        [self.chkBtn setImage:[UIImage imageNamed:@"uncheck.png"] forState:UIControlStateNormal];
        
        
        //Add star rating
        [self.starRatingView setStars:5 callbackBlock:^(NSNumber *newRating) {
            NSLog(@"didChangeRating: %@",newRating);
            rating = newRating;
        }];
        
        //scrollview setting
        self.mScrollView.scrollEnabled = YES;
        self.mScrollView.delegate = self;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
        
        tapGesture.cancelsTouchesInView = NO;
        
        [self.mScrollView addGestureRecognizer:tapGesture];
        
        self.mScrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        
        [self makeCornerRadiusControl:self.btnVideo radius:6.f backgroundcolor:[UIColor clearColor] borderColor:[UIColor lightGrayColor] borderWidth:2.f];
        [self makeCornerRadiusControl:self.btnAudio radius:6.f backgroundcolor:[UIColor clearColor] borderColor:[UIColor lightGrayColor] borderWidth:2.f];
        [self makeCornerRadiusControl:self.btnText radius:6.f backgroundcolor:[UIColor clearColor] borderColor:[UIColor lightGrayColor] borderWidth:2.f];
        
        [self makeCornerRadiusControl:self.btnPhoto radius:6.f backgroundcolor:[UIColor clearColor] borderColor:[UIColor darkGrayColor] borderWidth:2.f];
        [self makeCornerRadiusControl:self.btnAddPhoto radius:6.f backgroundcolor:[UIColor clearColor] borderColor:[UIColor lightGrayColor] borderWidth:2.f];
        [self makeCornerRadiusControl:self.btnSubmit radius:6.f backgroundcolor:[UIColor colorWithRed:42.f / 255.f green:68.f / 255.f blue:90.f / 255.f alpha:2.f] borderColor:[UIColor darkGrayColor] borderWidth:0.f];
        
        
        //init checkbox value as false
        isAcceptTerms = false;
        //Hide two photo button
        self.btnAddPhoto.hidden = YES;
        self.btnPhoto.hidden = YES;
        
        // Get Origin X, Y of two photo button and mView and photoview
        iBtnAddPhotoOriginX = self.btnAddPhoto.frame.origin.x;
        iBtnAddPhotoOriginY = self.btnAddPhoto.frame.origin.y;
        iBtnPhotoOriginX = self.btnPhoto.frame.origin.x;
        iBtnPhotoOriginY = self.btnPhoto.frame.origin.y;
        iPhotoViewOriginX = self.mphotoView.frame.origin.x;
        iPhotoViewOriginY = self.mphotoView.frame.origin.y;
        imViewOriginX = self.mView.frame.origin.x;
        imViewOriginY = self.mView.frame.origin.y;
        imBottonmenuX = self.m_viewBottomMenu.frame.origin.x;
        imBottonmenuY = self.m_viewBottomMenu.frame.origin.y;
        
        
    }
    
}

- (void) initAllMediaValues
{
    self.firstname_T.text = @"";
    self.lastname_T.text = @"";
    self.mailadr_T.text = @"";
    self.compname_T.text = @"";
    self.compcity_T.text = @"";
    self.compstate_T.text = @"";
    strReviewText = @"";
    
    imgAdditionalPhoto = nil;
    imgProofPurchasePhoto = nil;
    capturedVideoLink = nil;
    recordedAudioLink = nil;
    
    //    self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fScrollViewContentHeight);
    //
    //    self.mView.frame = CGRectMake(imViewOriginX, imViewOriginY, self.mView.frame.size.width, 0);
    //    self.mphotoView.frame = CGRectMake(iPhotoViewOriginX, iPhotoViewOriginY, self.mphotoView.frame.size.width, 0);
    //    self.btnPhoto.frame = CGRectMake(iBtnPhotoOriginX, iBtnPhotoOriginY, self.btnPhoto.frame.size.width, self.btnPhoto.frame.size.height);
    //    self.btnAddPhoto.frame = CGRectMake(iBtnAddPhotoOriginX, iBtnAddPhotoOriginY, self.btnAddPhoto.frame.size.width, self.btnAddPhoto.frame.size.height);
    //    self.m_viewBottomMenu.frame = CGRectMake(imBottonmenuX, imBottonmenuY, self.m_viewBottomMenu.frame.size.width, self.m_viewBottomMenu.frame.size.height);
    
    //scheduleType = 0;
    
}

- (void) makeCornerRadiusControl:(UIView *) targetView radius:(float) fRadius backgroundcolor:(UIColor *) bgColor borderColor:(UIColor *) borderColor borderWidth:(float) fBorderWidth
{
    targetView.backgroundColor = bgColor;
    targetView.layer.cornerRadius = fRadius;
    targetView.layer.borderColor = borderColor.CGColor;
    targetView.layer.borderWidth = fBorderWidth;
    targetView.clipsToBounds = YES;
    
}

- (void) hideKeyboard
{
    ReviewTextView* reviewTextView = (ReviewTextView *)[self.mView viewWithTag:400];
    if (reviewTextView)
    {
        [reviewTextView hideTextViewKeyboard];
    }
    
}

- (void)didChangeRating:(NSNumber*)newRating
{
    rating = newRating;
    NSLog(@"didChangeRating: %@",rating);
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

- (void) makeSelectedStatusForMedia
{
    
    [self.btnVideo setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.btnText setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.btnAudio setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.btnPhoto setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.btnAddPhoto setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
    [self makeCornerRadiusControl:self.btnPhoto radius:6.f backgroundcolor:[UIColor clearColor] borderColor:[UIColor lightGrayColor] borderWidth:1.f];
    [self makeCornerRadiusControl:self.btnAddPhoto radius:6.f backgroundcolor:[UIColor clearColor] borderColor:[UIColor lightGrayColor] borderWidth:1.f];
    [self makeCornerRadiusControl:self.btnVideo radius:6.f backgroundcolor:[UIColor clearColor] borderColor:[UIColor lightGrayColor] borderWidth:1.f];
    [self makeCornerRadiusControl:self.btnAudio radius:6.f backgroundcolor:[UIColor clearColor] borderColor:[UIColor lightGrayColor] borderWidth:1.f];
    [self makeCornerRadiusControl:self.btnText radius:6.f backgroundcolor:[UIColor clearColor] borderColor:[UIColor lightGrayColor] borderWidth:1.f];
    
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        self.btnText.titleLabel.font = [UIFont systemFontOfSize:16.f];
        self.btnVideo.titleLabel.font = [UIFont systemFontOfSize:16.f];
        self.btnAudio.titleLabel.font = [UIFont systemFontOfSize:16.f];
        
        if (eCurrentMediaType == NONE_MEDIA)
            return;
        
        if (eCurrentMediaType == PHOTO_MEDIA)
        {
            [self.btnPhoto setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            self.btnPhoto.titleLabel.font = [UIFont boldSystemFontOfSize:16.f];
            [self makeCornerRadiusControl:self.btnPhoto radius:6.f backgroundcolor:[UIColor clearColor] borderColor:[UIColor darkGrayColor] borderWidth:1.f];
        }
        
        if (eCurrentMediaType == ADDITIONAL_PHOTO_MEDIA)
        {
            [self.btnAddPhoto setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            self.btnAddPhoto.titleLabel.font = [UIFont boldSystemFontOfSize:14.f];
            [self makeCornerRadiusControl:self.btnAddPhoto radius:6.f backgroundcolor:[UIColor clearColor] borderColor:[UIColor darkGrayColor] borderWidth:1.f];
        }
        
        if (eCurrentMediaType == VIDEO_MEDIA)
        {
            [self.btnVideo setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            self.btnVideo.titleLabel.font = [UIFont boldSystemFontOfSize:16.f];
            [self makeCornerRadiusControl:self.btnVideo radius:6.f backgroundcolor:[UIColor clearColor] borderColor:[UIColor darkGrayColor] borderWidth:1.f];
        }
        
        if (eCurrentMediaType == AUDIO_MEDIA)
        {
            [self.btnAudio setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            self.btnAudio.titleLabel.font = [UIFont boldSystemFontOfSize:16.f];
            [self makeCornerRadiusControl:self.btnAudio radius:6.f backgroundcolor:[UIColor clearColor] borderColor:[UIColor darkGrayColor] borderWidth:1.f];
        }
        
        if (eCurrentMediaType == TEXT_MEDIA)
        {
            [self.btnText setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            self.btnText.titleLabel.font = [UIFont boldSystemFontOfSize:16.f];
            [self makeCornerRadiusControl:self.btnText radius:6.f backgroundcolor:[UIColor clearColor] borderColor:[UIColor darkGrayColor] borderWidth:1.f];
        }
    }
    else
    {
        //[ipad]
        self.btnText.titleLabel.font = [UIFont systemFontOfSize:30.f];
        self.btnVideo.titleLabel.font = [UIFont systemFontOfSize:30.f];
        self.btnAudio.titleLabel.font = [UIFont systemFontOfSize:30.f];
        
        if (eCurrentMediaType == NONE_MEDIA)
            return;
        
        if (eCurrentMediaType == PHOTO_MEDIA)
        {
            [self.btnPhoto setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            self.btnPhoto.titleLabel.font = [UIFont boldSystemFontOfSize:25.f];
            [self makeCornerRadiusControl:self.btnPhoto radius:6.f backgroundcolor:[UIColor clearColor] borderColor:[UIColor darkGrayColor] borderWidth:2.f];
        }
        
        if (eCurrentMediaType == ADDITIONAL_PHOTO_MEDIA)
        {
            [self.btnAddPhoto setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            self.btnAddPhoto.titleLabel.font = [UIFont boldSystemFontOfSize:20.f];
            [self makeCornerRadiusControl:self.btnAddPhoto radius:6.f backgroundcolor:[UIColor clearColor] borderColor:[UIColor darkGrayColor] borderWidth:2.f];
        }
        
        if (eCurrentMediaType == VIDEO_MEDIA)
        {
            [self.btnVideo setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            self.btnVideo.titleLabel.font = [UIFont boldSystemFontOfSize:30.f];
            [self makeCornerRadiusControl:self.btnVideo radius:6.f backgroundcolor:[UIColor clearColor] borderColor:[UIColor darkGrayColor] borderWidth:2.f];
        }
        
        if (eCurrentMediaType == AUDIO_MEDIA)
        {
            [self.btnAudio setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            self.btnAudio.titleLabel.font = [UIFont boldSystemFontOfSize:30.f];
            [self makeCornerRadiusControl:self.btnAudio radius:6.f backgroundcolor:[UIColor clearColor] borderColor:[UIColor darkGrayColor] borderWidth:2.f];
        }
        
        if (eCurrentMediaType == TEXT_MEDIA)
        {
            [self.btnText setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            self.btnText.titleLabel.font = [UIFont boldSystemFontOfSize:30.f];
            [self makeCornerRadiusControl:self.btnText radius:6.f backgroundcolor:[UIColor clearColor] borderColor:[UIColor darkGrayColor] borderWidth:2.f];
        }
    }
    
}

-(IBAction)onchkBtn:(id)sender{
    self.chkBtn.selected = !self.chkBtn.selected;// toggle the selected property, just a simple BOOL
    if(isAcceptTerms){
        isAcceptTerms = false;
        
    }else{
        isAcceptTerms = true;
    }
}

- (IBAction)onClickPhoto:(id)sender {
    /*
     if (eCurrentMediaType == ADDITIONAL_PHOTO_MEDIA) {
     eCurrentMediaType = PHOTO_MEDIA;
     [self makeSelectedStatusForMedia];
     return;
     }
     */
    if (bAlreadyPhotoMedia)
    {
        if(eCurrentMediaType == PHOTO_MEDIA)
        {
            eCurrentMediaType = NONE_MEDIA;
            
            CustomCameraView* currentPhotoCameraView = (CustomCameraView *)[self.mphotoView viewWithTag:100];
            if (currentPhotoCameraView)
            {
                [currentPhotoCameraView unInitCameraView];
                [currentPhotoCameraView removeFromSuperview];
                currentPhotoCameraView = nil;
            }
            
            [self makeSelectedStatusForMedia];
            bAlreadyPhotoMedia = false;
            
            //adjust position and size
            if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
            {
                //iPhone
                float fCurentScrollViewContentHeight = self.mScrollView.contentSize.height - (fCameraCanvasViewWidth + MARGIN_CONTROLS);
                self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurentScrollViewContentHeight);
                self.mphotoView.frame = CGRectMake(self.mphotoView.frame.origin.x, self.mphotoView.frame.origin.y, fCameraCanvasViewWidth, 0.f);
                self.m_viewBottomMenu.frame = CGRectMake(0.f, fCurentScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.m_viewBottomMenu.frame));
                
                return;
            }
            else if (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && ([UIScreen mainScreen].bounds.size.height == 1366 || [UIScreen mainScreen].bounds.size.width == 1366)))
            {
                float fCurentScrollViewContentHeight = self.mScrollView.contentSize.height - (fCameraCanvasViewWidth + MARGIN_CONTROLS);
                self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurentScrollViewContentHeight);
                self.mphotoView.frame = CGRectMake(228.f, self.mphotoView.frame.origin.y, fCameraCanvasViewWidth, 0.f);
                self.m_viewBottomMenu.frame = CGRectMake(178.f, fCurentScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame) - 20.f, 668.f, CGRectGetHeight(self.m_viewBottomMenu.frame));
                
                return;
            }
            else
            {
                //[ipad]
                float fCurentScrollViewContentHeight = self.mScrollView.contentSize.height - (fCameraCanvasViewWidth + MARGIN_CONTROLS);
                self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurentScrollViewContentHeight);
                self.mphotoView.frame = CGRectMake(100.f, self.mphotoView.frame.origin.y, fCameraCanvasViewWidth, 0.f);
                self.m_viewBottomMenu.frame = CGRectMake(50.f, fCurentScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame) - 20.f, 668.f, CGRectGetHeight(self.m_viewBottomMenu.frame));
                
                return;
            }
            
            
        }
        else //ecurrentMediaType is additional photo
        {
            eCurrentMediaType = PHOTO_MEDIA;
            //remove additioanl photo view.
            CustomCameraView* currentAddPhotoCameraView = (CustomCameraView *)[self.mphotoView viewWithTag:101];
            if (currentAddPhotoCameraView)
            {
                [currentAddPhotoCameraView unInitCameraView];
                [currentAddPhotoCameraView removeFromSuperview];
                currentAddPhotoCameraView = nil;
            }
            //and allocate proof photo view
            CustomCameraView* photoCameraView = [[CustomCameraView alloc] initWithFrame:self.mphotoView.bounds];
            photoCameraView.eSelectedCameraType = PHOTO_CAMERA;
            photoCameraView.delegate = self;
            photoCameraView.tag = 100;
            [self.mphotoView addSubview:photoCameraView];
            [photoCameraView initCameraView];
            
            [self makeSelectedStatusForMedia];
            return;
        }
        
    }
    
    //if video view exist then remove it but not adjust
    CustomCameraView* currentVideoCameraView = (CustomCameraView *)[self.mView viewWithTag:200];
    if (currentVideoCameraView)
    {
        [currentVideoCameraView unInitCameraView];
        [currentVideoCameraView removeFromSuperview];
        currentVideoCameraView = nil;
    }
    bAlreadyVideoMedia = false;
    
    bAlreadyPhotoMedia = true;
    
    if (bAlreadyTextMedia || bAlreadyAudioMedia)
    {
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
        {
            //iPhone
            eCurrentMediaType = PHOTO_MEDIA;
            [self makeSelectedStatusForMedia];
            
            float fCurrentScrollViewContentHeight = fScrollViewContentHeight + 2 * (fCameraCanvasViewWidth + MARGIN_CONTROLS);
            self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurrentScrollViewContentHeight);
            self.m_viewBottomMenu.frame = CGRectMake(0, fCurrentScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.m_viewBottomMenu.frame));
            self.mphotoView.frame = CGRectMake(MARGIN_CANVAS, self.btnAddPhoto.frame.origin.y + self.btnAddPhoto.frame.size.height + MARGIN_CONTROLS, fCameraCanvasViewWidth, fCameraCanvasViewWidth);
        }
        else if (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && ([UIScreen mainScreen].bounds.size.height == 1366 || [UIScreen mainScreen].bounds.size.width == 1366)))
        {
            eCurrentMediaType = PHOTO_MEDIA;
            [self makeSelectedStatusForMedia];
            
            float fCurrentScrollViewContentHeight = fScrollViewContentHeight + 2 * (fCameraCanvasViewWidth + MARGIN_CONTROLS);
            self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurrentScrollViewContentHeight);
            self.m_viewBottomMenu.frame = CGRectMake(178.f, fCurrentScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame) - 20.f, 668.f, CGRectGetHeight(self.m_viewBottomMenu.frame));
            self.mphotoView.frame = CGRectMake(228.f, self.btnAddPhoto.frame.origin.y + self.btnAddPhoto.frame.size.height + MARGIN_CONTROLS, fCameraCanvasViewWidth, fCameraCanvasViewWidth);
        }
        else
        {
            //[ipad]
            eCurrentMediaType = PHOTO_MEDIA;
            [self makeSelectedStatusForMedia];
            
            float fCurrentScrollViewContentHeight = fScrollViewContentHeight + 2 * (fCameraCanvasViewWidth + MARGIN_CONTROLS);
            self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurrentScrollViewContentHeight);
            self.m_viewBottomMenu.frame = CGRectMake(50.f, fCurrentScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame) - 20.f, 668.f, CGRectGetHeight(self.m_viewBottomMenu.frame));
            self.mphotoView.frame = CGRectMake(100.f, self.btnAddPhoto.frame.origin.y + self.btnAddPhoto.frame.size.height + MARGIN_CONTROLS, fCameraCanvasViewWidth, fCameraCanvasViewWidth);
        }
        
        
    }
    else
    {
        
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
        {
            //iPhone
            float fCurrentScrollViewContentHeight = fScrollViewContentHeight + fCameraCanvasViewWidth + MARGIN_CONTROLS;
            self.mView.frame = CGRectMake(self.mView.frame.origin.x, self.mView.frame.origin.y, fCameraCanvasViewWidth, 0.f);
            self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurrentScrollViewContentHeight);
            self.m_viewBottomMenu.frame = CGRectMake(0, fCurrentScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.m_viewBottomMenu.frame));
            self.mphotoView.frame = CGRectMake(MARGIN_CANVAS, self.btnPhoto.frame.origin.y + CGRectGetHeight(self.btnPhoto.frame) + MARGIN_CONTROLS, fCameraCanvasViewWidth, fCameraCanvasViewWidth);
        }
        else if (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && ([UIScreen mainScreen].bounds.size.height == 1366 || [UIScreen mainScreen].bounds.size.width == 1366)))
        {
            float fCurrentScrollViewContentHeight = fScrollViewContentHeight + fCameraCanvasViewWidth + MARGIN_CONTROLS;
            self.mView.frame = CGRectMake(self.mView.frame.origin.x, self.mView.frame.origin.y, fCameraCanvasViewWidth, 0.f);
            self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurrentScrollViewContentHeight);
            self.m_viewBottomMenu.frame = CGRectMake(178.f, fCurrentScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame) - 20.f, 668.f, CGRectGetHeight(self.m_viewBottomMenu.frame));
            self.mphotoView.frame = CGRectMake(228.f, self.btnPhoto.frame.origin.y + CGRectGetHeight(self.btnPhoto.frame) + MARGIN_CONTROLS, fCameraCanvasViewWidth, fCameraCanvasViewWidth);
        }
        else
        {
            //[ipad]
            float fCurrentScrollViewContentHeight = fScrollViewContentHeight + fCameraCanvasViewWidth + MARGIN_CONTROLS;
            self.mView.frame = CGRectMake(self.mView.frame.origin.x, self.mView.frame.origin.y, fCameraCanvasViewWidth, 0.f);
            self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurrentScrollViewContentHeight);
            self.m_viewBottomMenu.frame = CGRectMake(50.f, fCurrentScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame) - 20.f, 668.f, CGRectGetHeight(self.m_viewBottomMenu.frame));
            self.mphotoView.frame = CGRectMake(100.f, self.btnPhoto.frame.origin.y + CGRectGetHeight(self.btnPhoto.frame) + MARGIN_CONTROLS, fCameraCanvasViewWidth, fCameraCanvasViewWidth);
        }
        eCurrentMediaType = PHOTO_MEDIA;
        [self makeSelectedStatusForMedia];
        
        
        
    }
    
    eCurrentMediaType = PHOTO_MEDIA;
    
    CustomCameraView* photoCameraView = [[CustomCameraView alloc] initWithFrame:self.mphotoView.bounds];
    photoCameraView.eSelectedCameraType = PHOTO_CAMERA;
    photoCameraView.delegate = self;
    photoCameraView.tag = 100;
    [self.mphotoView addSubview:photoCameraView];
    [photoCameraView initCameraView];
}

- (IBAction)onClickVideo:(id)sender {
    //schedule type is 1
    scheduleType = 1;
    
    //Show hidden two photo button
    self.btnAddPhoto.hidden = YES;
    self.btnPhoto.hidden = YES;
    
    if (bAlreadyVideoMedia)
    {
        eCurrentMediaType = NONE_MEDIA;
        [self makeSelectedStatusForMedia];
        bAlreadyVideoMedia = false;
        
        CustomCameraView* currentVideoCameraView = (CustomCameraView *)[self.mView viewWithTag:200];
        if (currentVideoCameraView)
        {
            [currentVideoCameraView unInitCameraView];
            [currentVideoCameraView removeFromSuperview];
            currentVideoCameraView = nil;
        }
        
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
        {
            float fCurentScrollViewContentHeight = self.mScrollView.contentSize.height - (fCameraCanvasViewWidth + MARGIN_CONTROLS);
            self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurentScrollViewContentHeight);
            self.btnAddPhoto.frame = CGRectMake(iBtnAddPhotoOriginX, iBtnAddPhotoOriginY, self.btnAddPhoto.frame.size.width, self.btnAddPhoto.frame.size.height);
            self.btnPhoto.frame = CGRectMake(iBtnPhotoOriginX, iBtnPhotoOriginY, self.btnPhoto.frame.size.width, self.btnPhoto.frame.size.height);
            self.m_viewBottomMenu.frame = CGRectMake(0, fCurentScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.m_viewBottomMenu.frame));
            self.mView.frame = CGRectMake(imViewOriginX, imViewOriginY, fCameraCanvasViewWidth, 0.f);
            
            return;
        }
        else if (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && ([UIScreen mainScreen].bounds.size.height == 1366 || [UIScreen mainScreen].bounds.size.width == 1366)))
        {
            float fCurentScrollViewContentHeight = self.mScrollView.contentSize.height - (fCameraCanvasViewWidth + MARGIN_CONTROLS);
            self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurentScrollViewContentHeight);
            self.btnAddPhoto.frame = CGRectMake(iBtnAddPhotoOriginX, iBtnAddPhotoOriginY, self.btnAddPhoto.frame.size.width, self.btnAddPhoto.frame.size.height);
            self.btnPhoto.frame = CGRectMake(iBtnPhotoOriginX, iBtnPhotoOriginY, self.btnPhoto.frame.size.width, self.btnPhoto.frame.size.height);
            self.m_viewBottomMenu.frame = CGRectMake(178.f, fCurentScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame) - 20.f, 668.f, CGRectGetHeight(self.m_viewBottomMenu.frame));
            self.mView.frame = CGRectMake(228.f, imViewOriginY, fCameraCanvasViewWidth, 0.f);
            
            return;
        }
        else
        {
            //[ipad]
            float fCurentScrollViewContentHeight = self.mScrollView.contentSize.height - (fCameraCanvasViewWidth + MARGIN_CONTROLS);
            self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurentScrollViewContentHeight);
            self.btnAddPhoto.frame = CGRectMake(iBtnAddPhotoOriginX, iBtnAddPhotoOriginY, self.btnAddPhoto.frame.size.width, self.btnAddPhoto.frame.size.height);
            self.btnPhoto.frame = CGRectMake(iBtnPhotoOriginX, iBtnPhotoOriginY, self.btnPhoto.frame.size.width, self.btnPhoto.frame.size.height);
            self.m_viewBottomMenu.frame = CGRectMake(50.f, fCurentScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame) - 20.f, 668.f, CGRectGetHeight(self.m_viewBottomMenu.frame));
            self.mView.frame = CGRectMake(100.f, imViewOriginY, fCameraCanvasViewWidth, 0.f);
            
            return;
        }
        
    }
    
    //no video view
    if(eCurrentMediaType == PHOTO_MEDIA)
    {
        CustomCameraView* currentPhotoCameraView = (CustomCameraView *)[self.mphotoView viewWithTag:100];
        if (currentPhotoCameraView)
        {
            [currentPhotoCameraView unInitCameraView];
            [currentPhotoCameraView removeFromSuperview];
            currentPhotoCameraView = nil;
        }
    }
    else if (eCurrentMediaType == ADDITIONAL_PHOTO_MEDIA){
        
        CustomCameraView* currentAddPhotoCameraView = (CustomCameraView *)[self.mphotoView viewWithTag:101];
        if (currentAddPhotoCameraView)
        {
            [currentAddPhotoCameraView unInitCameraView];
            [currentAddPhotoCameraView removeFromSuperview];
            currentAddPhotoCameraView = nil;
        }
    }
    
    RecordAudioView* recordAudioView = (RecordAudioView *)[self.mView viewWithTag:300];
    if (recordAudioView)
    {
        [recordAudioView removeFromSuperview];
        recordAudioView = nil;
    }
    
    ReviewTextView* reviewTextView = (ReviewTextView *)[self.mView viewWithTag:400];
    if (reviewTextView)
    {
        strReviewText = reviewTextView.m_txtView.text;
        [reviewTextView removeFromSuperview];
        reviewTextView = nil;
    }
    
    bAlreadyPhotoMedia = false;
    bAlreadyAudioMedia = false;
    bAlreadyTextMedia = false;
    bAlreadyVideoMedia = true;
    
    eCurrentMediaType = VIDEO_MEDIA;
    [self makeSelectedStatusForMedia];
    
    
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        //iPhone
        //adjust position
        self.mphotoView.frame = CGRectMake(self.mphotoView.frame.origin.x, self.mphotoView.frame.origin.y, fCameraCanvasViewWidth, 0.f);
        float fCurentScrollViewContentHeight = fScrollViewContentHeight + fCameraCanvasViewWidth + MARGIN_CONTROLS;
        self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurentScrollViewContentHeight);
        
        //adjust positions
        self.m_viewBottomMenu.frame = CGRectMake(0, fCurentScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.m_viewBottomMenu.frame));
        self.btnPhoto.frame = CGRectMake(iBtnPhotoOriginX, iBtnPhotoOriginY + fCameraCanvasViewWidth + MARGIN_CONTROLS, self.btnPhoto.frame.size.width, self.btnPhoto.frame.size.height);
        self.btnAddPhoto.frame = CGRectMake(iBtnPhotoOriginX, iBtnPhotoOriginY + fCameraCanvasViewWidth + MARGIN_CONTROLS, self.btnAddPhoto.frame.size.width, self.btnPhoto.frame.size.height);
        //    self.viewChooseMedia.frame = CGRectMake(self.viewChooseMedia.frame.origin.x, fOriginMenuViewPosY, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.viewChooseMedia.frame));
        self.mView.frame = CGRectMake(MARGIN_CANVAS, self.viewChooseMedia.frame.origin.y + CGRectGetHeight(self.viewChooseMedia.frame) + MARGIN_CONTROLS, fCameraCanvasViewWidth, fCameraCanvasViewWidth);
    }
    else if (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && ([UIScreen mainScreen].bounds.size.height == 1366 || [UIScreen mainScreen].bounds.size.width == 1366)))
    {
        self.mphotoView.frame = CGRectMake(self.mphotoView.frame.origin.x, self.mphotoView.frame.origin.y, fCameraCanvasViewWidth, 0.f);
        float fCurentScrollViewContentHeight = fScrollViewContentHeight + fCameraCanvasViewWidth + MARGIN_CONTROLS;
        self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurentScrollViewContentHeight);
        
        //adjust positions
        self.m_viewBottomMenu.frame = CGRectMake(178.f, fCurentScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame) - 20.f, 668.f, CGRectGetHeight(self.m_viewBottomMenu.frame));
        self.btnPhoto.frame = CGRectMake(iBtnPhotoOriginX, iBtnPhotoOriginY + fCameraCanvasViewWidth + MARGIN_CONTROLS, self.btnPhoto.frame.size.width, self.btnPhoto.frame.size.height);
        self.btnAddPhoto.frame = CGRectMake(iBtnPhotoOriginX, iBtnPhotoOriginY + fCameraCanvasViewWidth + MARGIN_CONTROLS, self.btnAddPhoto.frame.size.width, self.btnPhoto.frame.size.height);
        self.mView.frame = CGRectMake(228.f, self.viewChooseMedia.frame.origin.y + CGRectGetHeight(self.viewChooseMedia.frame) + MARGIN_CONTROLS + 200.f, fCameraCanvasViewWidth, fCameraCanvasViewWidth);
    }
    else
    {
        //[ipad]
        //adjust position
        self.mphotoView.frame = CGRectMake(self.mphotoView.frame.origin.x, self.mphotoView.frame.origin.y, fCameraCanvasViewWidth, 0.f);
        float fCurentScrollViewContentHeight = fScrollViewContentHeight + fCameraCanvasViewWidth + MARGIN_CONTROLS;
        self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurentScrollViewContentHeight);
        
        //adjust positions
        self.m_viewBottomMenu.frame = CGRectMake(50.f, fCurentScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame) - 20.f, 668.f, CGRectGetHeight(self.m_viewBottomMenu.frame));
        self.btnPhoto.frame = CGRectMake(iBtnPhotoOriginX, iBtnPhotoOriginY + fCameraCanvasViewWidth + MARGIN_CONTROLS, self.btnPhoto.frame.size.width, self.btnPhoto.frame.size.height);
        self.btnAddPhoto.frame = CGRectMake(iBtnPhotoOriginX, iBtnPhotoOriginY + fCameraCanvasViewWidth + MARGIN_CONTROLS, self.btnAddPhoto.frame.size.width, self.btnPhoto.frame.size.height);
        self.mView.frame = CGRectMake(100.f, self.viewChooseMedia.frame.origin.y + CGRectGetHeight(self.viewChooseMedia.frame) + MARGIN_CONTROLS, fCameraCanvasViewWidth, fCameraCanvasViewWidth);
    }
    
    
    
    //init video camera
    CustomCameraView* videoCameraView = [[CustomCameraView alloc] initWithFrame:self.mView.bounds];
    videoCameraView.eSelectedCameraType = VIDEO_CAMERA;
    videoCameraView.tag = 200;
    videoCameraView.delegate = self;
    [self.mView addSubview:videoCameraView];
    [videoCameraView initCameraView];
    
}

- (IBAction)onClickAudio:(id)sender {
    //schedule type is 2
    scheduleType = 2;
    
    //Show hidden two photo button
    self.btnAddPhoto.hidden = NO;
    self.btnPhoto.hidden = NO;
    
    CustomCameraView* currentVideoCameraView = (CustomCameraView *)[self.mView viewWithTag:200];
    if (currentVideoCameraView)
    {
        [currentVideoCameraView unInitCameraView];
        [currentVideoCameraView removeFromSuperview];
        currentVideoCameraView = nil;
    }
    
    bAlreadyVideoMedia = false;
    
    ReviewTextView* reviewTextView = (ReviewTextView *)[self.mView viewWithTag:400];
    if (reviewTextView)
    {
        strReviewText = reviewTextView.m_txtView.text;
        [reviewTextView removeFromSuperview];
        reviewTextView = nil;
    }
    
    bAlreadyTextMedia = false;
    
    //if audio view exist
    if (bAlreadyAudioMedia)
    {
        RecordAudioView* recordAudioView = (RecordAudioView *)[self.mView viewWithTag:300];
        if (recordAudioView)
        {
            [recordAudioView removeFromSuperview];
            recordAudioView = nil;
        }
        
        bAlreadyAudioMedia = false;
        
        //if exist photoview then remove it and adjust position
        if(bAlreadyPhotoMedia)
        {
            if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
            {
                //iPhone
                //remove photo view and adjust position.
                float fCurrentScrollViewContentHeight = self.mScrollView.contentSize.height -  2 * fCameraCanvasViewWidth - MARGIN_CONTROLS;
                self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurrentScrollViewContentHeight);
                self.btnAddPhoto.frame = CGRectMake(iBtnAddPhotoOriginX, iBtnAddPhotoOriginY, CGRectGetWidth(self.btnAddPhoto.frame), CGRectGetHeight(self.btnAddPhoto.frame));
                self.btnPhoto.frame = CGRectMake(iBtnPhotoOriginX, iBtnPhotoOriginY, CGRectGetWidth(self.btnPhoto.frame), CGRectGetHeight(self.btnPhoto.frame));
                self.mphotoView.frame = CGRectMake(iPhotoViewOriginX, iPhotoViewOriginY, fCameraCanvasViewWidth, 0.f);
                self.m_viewBottomMenu.frame = CGRectMake(0, fScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.m_viewBottomMenu.frame));
                self.mView.frame = CGRectMake(MARGIN_CANVAS, self.viewChooseMedia.frame.origin.y + CGRectGetHeight(self.viewChooseMedia.frame) + MARGIN_CONTROLS, fCameraCanvasViewWidth, 0);
            }
            else if (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && ([UIScreen mainScreen].bounds.size.height == 1366 || [UIScreen mainScreen].bounds.size.width == 1366)))
            {
                float fCurrentScrollViewContentHeight = self.mScrollView.contentSize.height -  2 * fCameraCanvasViewWidth - MARGIN_CONTROLS;
                self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurrentScrollViewContentHeight);
                self.btnAddPhoto.frame = CGRectMake(iBtnAddPhotoOriginX, iBtnAddPhotoOriginY, CGRectGetWidth(self.btnAddPhoto.frame), CGRectGetHeight(self.btnAddPhoto.frame));
                self.btnPhoto.frame = CGRectMake(iBtnPhotoOriginX, iBtnPhotoOriginY, CGRectGetWidth(self.btnPhoto.frame), CGRectGetHeight(self.btnPhoto.frame));
                self.mphotoView.frame = CGRectMake(228.f, iPhotoViewOriginY, fCameraCanvasViewWidth, 0.f);
                self.m_viewBottomMenu.frame = CGRectMake(178.f, fScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame), 668.f, CGRectGetHeight(self.m_viewBottomMenu.frame));
                self.mView.frame = CGRectMake(228.f, self.viewChooseMedia.frame.origin.y + CGRectGetHeight(self.viewChooseMedia.frame) + MARGIN_CONTROLS, fCameraCanvasViewWidth, 0);
            }
            else
            {
                //[ipad]
                //remove photo view and adjust position.
                float fCurrentScrollViewContentHeight = self.mScrollView.contentSize.height -  2 * fCameraCanvasViewWidth - MARGIN_CONTROLS;
                self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurrentScrollViewContentHeight);
                self.btnAddPhoto.frame = CGRectMake(iBtnAddPhotoOriginX, iBtnAddPhotoOriginY, CGRectGetWidth(self.btnAddPhoto.frame), CGRectGetHeight(self.btnAddPhoto.frame));
                self.btnPhoto.frame = CGRectMake(iBtnPhotoOriginX, iBtnPhotoOriginY, CGRectGetWidth(self.btnPhoto.frame), CGRectGetHeight(self.btnPhoto.frame));
                self.mphotoView.frame = CGRectMake(100.f, iPhotoViewOriginY, fCameraCanvasViewWidth, 0.f);
                self.m_viewBottomMenu.frame = CGRectMake(50.f, fScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame), 668.f, CGRectGetHeight(self.m_viewBottomMenu.frame));
                self.mView.frame = CGRectMake(100.f, self.viewChooseMedia.frame.origin.y + CGRectGetHeight(self.viewChooseMedia.frame) + MARGIN_CONTROLS, fCameraCanvasViewWidth, 0);
            }
            
            
            if(eCurrentMediaType == PHOTO_MEDIA)
            {
                CustomCameraView* currentPhotoCameraView = (CustomCameraView *)[self.mphotoView viewWithTag:100];
                if (currentPhotoCameraView)
                {
                    [currentPhotoCameraView unInitCameraView];
                    [currentPhotoCameraView removeFromSuperview];
                    currentPhotoCameraView = nil;
                }
            }
            else if (eCurrentMediaType == ADDITIONAL_PHOTO_MEDIA){
                
                CustomCameraView* currentAddPhotoCameraView = (CustomCameraView *)[self.mphotoView viewWithTag:101];
                if (currentAddPhotoCameraView)
                {
                    [currentAddPhotoCameraView unInitCameraView];
                    [currentAddPhotoCameraView removeFromSuperview];
                    currentAddPhotoCameraView = nil;
                }
            }
            
            eCurrentMediaType = NONE_MEDIA;
            [self makeSelectedStatusForMedia];
            bAlreadyPhotoMedia = false;
            return;
        }
        
        eCurrentMediaType = NONE_MEDIA;
        [self makeSelectedStatusForMedia];
        
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
        {
            //iPhone
            float fCurrentScrollViewContentHeight = self.mScrollView.contentSize.height - (fCameraCanvasViewWidth + MARGIN_CONTROLS);
            self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurrentScrollViewContentHeight);
            self.mView.frame = CGRectMake(MARGIN_CANVAS, self.viewChooseMedia.frame.origin.y + CGRectGetHeight(self.viewChooseMedia.frame) + MARGIN_CONTROLS, fCameraCanvasViewWidth, 0);
            self.btnAddPhoto.frame = CGRectMake(iBtnAddPhotoOriginX, iBtnAddPhotoOriginY, CGRectGetWidth(self.btnAddPhoto.frame), CGRectGetHeight(self.btnAddPhoto.frame));
            self.btnPhoto.frame = CGRectMake(iBtnPhotoOriginX, iBtnPhotoOriginY, CGRectGetWidth(self.btnPhoto.frame), CGRectGetHeight(self.btnPhoto.frame));
            self.m_viewBottomMenu.frame = CGRectMake(0, fScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.m_viewBottomMenu.frame));
            
            return;
        }
        else if (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && ([UIScreen mainScreen].bounds.size.height == 1366 || [UIScreen mainScreen].bounds.size.width == 1366)))
        {
            float fCurrentScrollViewContentHeight = self.mScrollView.contentSize.height - (fCameraCanvasViewWidth + MARGIN_CONTROLS);
            self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurrentScrollViewContentHeight);
            self.mView.frame = CGRectMake(100.f, self.viewChooseMedia.frame.origin.y + CGRectGetHeight(self.viewChooseMedia.frame) + MARGIN_CONTROLS, fCameraCanvasViewWidth, 0);
            self.btnAddPhoto.frame = CGRectMake(iBtnAddPhotoOriginX, iBtnAddPhotoOriginY, CGRectGetWidth(self.btnAddPhoto.frame), CGRectGetHeight(self.btnAddPhoto.frame));
            self.btnPhoto.frame = CGRectMake(iBtnPhotoOriginX, iBtnPhotoOriginY, CGRectGetWidth(self.btnPhoto.frame), CGRectGetHeight(self.btnPhoto.frame));
            self.m_viewBottomMenu.frame = CGRectMake(178.f, fScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame), 668.f, CGRectGetHeight(self.m_viewBottomMenu.frame));
            
            return;
        }
        else
        {
            //[ipad]
            float fCurrentScrollViewContentHeight = self.mScrollView.contentSize.height - (fCameraCanvasViewWidth + MARGIN_CONTROLS);
            self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurrentScrollViewContentHeight);
            self.mView.frame = CGRectMake(100.f, self.viewChooseMedia.frame.origin.y + CGRectGetHeight(self.viewChooseMedia.frame) + MARGIN_CONTROLS, fCameraCanvasViewWidth, 0);
            self.btnAddPhoto.frame = CGRectMake(iBtnAddPhotoOriginX, iBtnAddPhotoOriginY, CGRectGetWidth(self.btnAddPhoto.frame), CGRectGetHeight(self.btnAddPhoto.frame));
            self.btnPhoto.frame = CGRectMake(iBtnPhotoOriginX, iBtnPhotoOriginY, CGRectGetWidth(self.btnPhoto.frame), CGRectGetHeight(self.btnPhoto.frame));
            self.m_viewBottomMenu.frame = CGRectMake(50.f, fScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame), 668.f, CGRectGetHeight(self.m_viewBottomMenu.frame));
            
            return;
        }
        
    }
    
    //if no Audio View
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        //iPhone
        self.btnAddPhoto.hidden = NO;
        self.btnPhoto.hidden = NO;
        
        float fCurrentScrollViewContentHeight = fScrollViewContentHeight + (fCameraCanvasViewWidth + MARGIN_CONTROLS);
        self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurrentScrollViewContentHeight);
        self.mView.frame = CGRectMake(MARGIN_CANVAS, self.viewChooseMedia.frame.origin.y + CGRectGetHeight(self.viewChooseMedia.frame) + MARGIN_CONTROLS, fCameraCanvasViewWidth, fCameraCanvasViewWidth);
        self.btnAddPhoto.frame = CGRectMake(iBtnAddPhotoOriginX, iBtnAddPhotoOriginY + fCameraCanvasViewWidth, self.btnAddPhoto.frame.size.width, self.btnAddPhoto.frame.size.height);
        self.btnPhoto.frame = CGRectMake(iBtnPhotoOriginX, iBtnPhotoOriginY + fCameraCanvasViewWidth, self.btnPhoto.frame.size.width, self.btnPhoto.frame.size.height);
        self.mphotoView.frame = CGRectMake(iPhotoViewOriginX, iPhotoViewOriginY + (fCameraCanvasViewWidth + MARGIN_CONTROLS), fCameraCanvasViewWidth, 0.f);
        self.m_viewBottomMenu.frame = CGRectMake(0, fCurrentScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.m_viewBottomMenu.frame));
    }
    
    else if (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && ([UIScreen mainScreen].bounds.size.height == 1366 || [UIScreen mainScreen].bounds.size.width == 1366)))
    {
        //[ipad]
        self.btnAddPhoto.hidden = NO;
        self.btnPhoto.hidden = NO;
        
        float fCurrentScrollViewContentHeight = fScrollViewContentHeight + (fCameraCanvasViewWidth + MARGIN_CONTROLS);
        self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurrentScrollViewContentHeight);
        self.mView.frame = CGRectMake(228.f, self.viewChooseMedia.frame.origin.y + CGRectGetHeight(self.viewChooseMedia.frame) + MARGIN_CONTROLS + 200.f, fCameraCanvasViewWidth, fCameraCanvasViewWidth);
        self.btnAddPhoto.frame = CGRectMake(iBtnAddPhotoOriginX, iBtnAddPhotoOriginY + fCameraCanvasViewWidth, self.btnAddPhoto.frame.size.width, self.btnAddPhoto.frame.size.height);
        self.btnPhoto.frame = CGRectMake(iBtnPhotoOriginX, iBtnPhotoOriginY + fCameraCanvasViewWidth, self.btnPhoto.frame.size.width, self.btnPhoto.frame.size.height);
        self.mphotoView.frame = CGRectMake(100.f, iPhotoViewOriginY + (fCameraCanvasViewWidth + MARGIN_CONTROLS), fCameraCanvasViewWidth, 0.f);
        self.m_viewBottomMenu.frame = CGRectMake(178.f, fCurrentScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame) - 20.f, 668.f, CGRectGetHeight(self.m_viewBottomMenu.frame));
    }
    else
    {
        //[ipad]
        self.btnAddPhoto.hidden = NO;
        self.btnPhoto.hidden = NO;
        
        float fCurrentScrollViewContentHeight = fScrollViewContentHeight + (fCameraCanvasViewWidth + MARGIN_CONTROLS);
        self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurrentScrollViewContentHeight);
        self.mView.frame = CGRectMake(100.f, self.viewChooseMedia.frame.origin.y + CGRectGetHeight(self.viewChooseMedia.frame) + MARGIN_CONTROLS, fCameraCanvasViewWidth, fCameraCanvasViewWidth);
        self.btnAddPhoto.frame = CGRectMake(iBtnAddPhotoOriginX, iBtnAddPhotoOriginY + fCameraCanvasViewWidth, self.btnAddPhoto.frame.size.width, self.btnAddPhoto.frame.size.height);
        self.btnPhoto.frame = CGRectMake(iBtnPhotoOriginX, iBtnPhotoOriginY + fCameraCanvasViewWidth, self.btnPhoto.frame.size.width, self.btnPhoto.frame.size.height);
        self.mphotoView.frame = CGRectMake(100.f, iPhotoViewOriginY + (fCameraCanvasViewWidth + MARGIN_CONTROLS), fCameraCanvasViewWidth, 0.f);
        self.m_viewBottomMenu.frame = CGRectMake(50.f, fCurrentScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame) - 20.f, 668.f, CGRectGetHeight(self.m_viewBottomMenu.frame));
    }
    
    
    
    
    //locate Audio View in mView.
    bAlreadyAudioMedia = true;
    
    if(bAlreadyPhotoMedia)
    {
        if(eCurrentMediaType == PHOTO_MEDIA)
        {
            CustomCameraView* currentPhotoCameraView = (CustomCameraView *)[self.mphotoView viewWithTag:100];
            if (currentPhotoCameraView)
            {
                [currentPhotoCameraView unInitCameraView];
                [currentPhotoCameraView removeFromSuperview];
                currentPhotoCameraView = nil;
            }
        }
        else if (eCurrentMediaType == ADDITIONAL_PHOTO_MEDIA){
            
            CustomCameraView* currentAddPhotoCameraView = (CustomCameraView *)[self.mphotoView viewWithTag:101];
            if (currentAddPhotoCameraView)
            {
                [currentAddPhotoCameraView unInitCameraView];
                [currentAddPhotoCameraView removeFromSuperview];
                currentAddPhotoCameraView = nil;
            }
        }
        bAlreadyPhotoMedia = false;
        
    }
    
    eCurrentMediaType = AUDIO_MEDIA;
    [self makeSelectedStatusForMedia];
    
    RecordAudioView* recordAudioView = [[[NSBundle mainBundle] loadNibNamed:@"RecordAudioView" owner:self options:nil] objectAtIndex:0];
    recordAudioView.frame = self.mView.bounds;
    recordAudioView.tag = 300;
    recordAudioView.delegate = self;
    
    [self.mView addSubview:recordAudioView];
    
}

- (IBAction)onClickText:(id)sender {
    //schedule type is 3
    scheduleType = 3;
    
    //Show hidden two photo button
    self.btnAddPhoto.hidden = NO;
    self.btnPhoto.hidden = NO;
    
    CustomCameraView* currentVideoCameraView = (CustomCameraView *)[self.mView viewWithTag:200];
    if (currentVideoCameraView)
    {
        [currentVideoCameraView unInitCameraView];
        [currentVideoCameraView removeFromSuperview];
        currentVideoCameraView = nil;
    }
    bAlreadyVideoMedia = false;
    
    RecordAudioView* recordAudioView = (RecordAudioView *)[self.mView viewWithTag:300];
    if (recordAudioView)
    {
        [recordAudioView removeFromSuperview];
        recordAudioView = nil;
    }
    bAlreadyAudioMedia = false;
    
    //if audio view exist
    if (bAlreadyTextMedia)
    {
        ReviewTextView* reviewTextView = (ReviewTextView *)[self.mView viewWithTag:400];
        if (reviewTextView)
        {
            strReviewText = reviewTextView.m_txtView.text;
            [reviewTextView removeFromSuperview];
            reviewTextView = nil;
        }
        
        bAlreadyTextMedia = false;
        
        //if exist photoview then remove it and adjust position
        if(bAlreadyPhotoMedia)
        {
            //remove photo view and adjust position.
            if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
            {
                float fCurrentScrollViewContentHeight = self.mScrollView.contentSize.height -  2 * fCameraCanvasViewWidth - MARGIN_CONTROLS;
                self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurrentScrollViewContentHeight);
                self.btnAddPhoto.frame = CGRectMake(iBtnAddPhotoOriginX, iBtnAddPhotoOriginY, CGRectGetWidth(self.btnAddPhoto.frame), CGRectGetHeight(self.btnAddPhoto.frame));
                self.btnPhoto.frame = CGRectMake(iBtnPhotoOriginX, iBtnPhotoOriginY, CGRectGetWidth(self.btnPhoto.frame), CGRectGetHeight(self.btnPhoto.frame));
                self.mphotoView.frame = CGRectMake(iPhotoViewOriginX, iPhotoViewOriginY, fCameraCanvasViewWidth, 0.f);
                self.m_viewBottomMenu.frame = CGRectMake(0, fScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.m_viewBottomMenu.frame));
                self.mView.frame = CGRectMake(MARGIN_CANVAS, self.viewChooseMedia.frame.origin.y + CGRectGetHeight(self.viewChooseMedia.frame) + MARGIN_CONTROLS, fCameraCanvasViewWidth, 0);
            }
            else if (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && ([UIScreen mainScreen].bounds.size.height == 1366 || [UIScreen mainScreen].bounds.size.width == 1366)))
            {
                float fCurrentScrollViewContentHeight = self.mScrollView.contentSize.height -  2 * fCameraCanvasViewWidth - MARGIN_CONTROLS;
                self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurrentScrollViewContentHeight);
                self.btnAddPhoto.frame = CGRectMake(iBtnAddPhotoOriginX, iBtnAddPhotoOriginY, CGRectGetWidth(self.btnAddPhoto.frame), CGRectGetHeight(self.btnAddPhoto.frame));
                self.btnPhoto.frame = CGRectMake(iBtnPhotoOriginX, iBtnPhotoOriginY, CGRectGetWidth(self.btnPhoto.frame), CGRectGetHeight(self.btnPhoto.frame));
                self.mphotoView.frame = CGRectMake(228.f, iPhotoViewOriginY, fCameraCanvasViewWidth, 0.f);
                self.m_viewBottomMenu.frame = CGRectMake(178.f, fScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame), 668.f, CGRectGetHeight(self.m_viewBottomMenu.frame));
                self.mView.frame = CGRectMake(228.f, self.viewChooseMedia.frame.origin.y + CGRectGetHeight(self.viewChooseMedia.frame) + MARGIN_CONTROLS, fCameraCanvasViewWidth, 0);
            }
            else
            {
                //[ipad]
                float fCurrentScrollViewContentHeight = self.mScrollView.contentSize.height -  2 * fCameraCanvasViewWidth - MARGIN_CONTROLS;
                self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurrentScrollViewContentHeight);
                self.btnAddPhoto.frame = CGRectMake(iBtnAddPhotoOriginX, iBtnAddPhotoOriginY, CGRectGetWidth(self.btnAddPhoto.frame), CGRectGetHeight(self.btnAddPhoto.frame));
                self.btnPhoto.frame = CGRectMake(iBtnPhotoOriginX, iBtnPhotoOriginY, CGRectGetWidth(self.btnPhoto.frame), CGRectGetHeight(self.btnPhoto.frame));
                self.mphotoView.frame = CGRectMake(iPhotoViewOriginX, iPhotoViewOriginY, fCameraCanvasViewWidth, 0.f);
                self.m_viewBottomMenu.frame = CGRectMake(50.f, fScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame), 668.f, CGRectGetHeight(self.m_viewBottomMenu.frame));
                self.mView.frame = CGRectMake(100.f, self.viewChooseMedia.frame.origin.y + CGRectGetHeight(self.viewChooseMedia.frame) + MARGIN_CONTROLS, fCameraCanvasViewWidth, 0);
            }
            
            
            
            if(eCurrentMediaType == PHOTO_MEDIA)
            {
                CustomCameraView* currentPhotoCameraView = (CustomCameraView *)[self.mphotoView viewWithTag:100];
                if (currentPhotoCameraView)
                {
                    [currentPhotoCameraView unInitCameraView];
                    [currentPhotoCameraView removeFromSuperview];
                    currentPhotoCameraView = nil;
                }
            }
            else if (eCurrentMediaType == ADDITIONAL_PHOTO_MEDIA){
                
                CustomCameraView* currentAddPhotoCameraView = (CustomCameraView *)[self.mphotoView viewWithTag:101];
                if (currentAddPhotoCameraView)
                {
                    [currentAddPhotoCameraView unInitCameraView];
                    [currentAddPhotoCameraView removeFromSuperview];
                    currentAddPhotoCameraView = nil;
                }
            }
            
            eCurrentMediaType = NONE_MEDIA;
            [self makeSelectedStatusForMedia];
            
            bAlreadyPhotoMedia = false;
            return;
            
        }
        
        eCurrentMediaType = NONE_MEDIA;
        [self makeSelectedStatusForMedia];
        
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
        {
            float fCurrentScrollViewContentHeight = self.mScrollView.contentSize.height - (fCameraCanvasViewWidth + MARGIN_CONTROLS);
            self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurrentScrollViewContentHeight);
            self.mView.frame = CGRectMake(MARGIN_CANVAS, self.viewChooseMedia.frame.origin.y + CGRectGetHeight(self.viewChooseMedia.frame) + MARGIN_CONTROLS, fCameraCanvasViewWidth, 0);
            self.btnAddPhoto.frame = CGRectMake(iBtnAddPhotoOriginX, iBtnAddPhotoOriginY, CGRectGetWidth(self.btnAddPhoto.frame), CGRectGetHeight(self.btnAddPhoto.frame));
            self.btnPhoto.frame = CGRectMake(iBtnPhotoOriginX, iBtnPhotoOriginY, CGRectGetWidth(self.btnPhoto.frame), CGRectGetHeight(self.btnPhoto.frame));
            self.m_viewBottomMenu.frame = CGRectMake(0, fScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.m_viewBottomMenu.frame));
            
            return;
        }
        else if (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && ([UIScreen mainScreen].bounds.size.height == 1366 || [UIScreen mainScreen].bounds.size.width == 1366)))
        {
            float fCurrentScrollViewContentHeight = self.mScrollView.contentSize.height - (fCameraCanvasViewWidth + MARGIN_CONTROLS);
            self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurrentScrollViewContentHeight);
            self.mView.frame = CGRectMake(100.f, self.viewChooseMedia.frame.origin.y + CGRectGetHeight(self.viewChooseMedia.frame) + MARGIN_CONTROLS, fCameraCanvasViewWidth, 0);
            self.btnAddPhoto.frame = CGRectMake(iBtnAddPhotoOriginX, iBtnAddPhotoOriginY, CGRectGetWidth(self.btnAddPhoto.frame), CGRectGetHeight(self.btnAddPhoto.frame));
            self.btnPhoto.frame = CGRectMake(iBtnPhotoOriginX, iBtnPhotoOriginY, CGRectGetWidth(self.btnPhoto.frame), CGRectGetHeight(self.btnPhoto.frame));
            self.m_viewBottomMenu.frame = CGRectMake(178.f, fScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame), 668.f, CGRectGetHeight(self.m_viewBottomMenu.frame));
            
            return;
        }
        else
        {
            //[ipad]
            float fCurrentScrollViewContentHeight = self.mScrollView.contentSize.height - (fCameraCanvasViewWidth + MARGIN_CONTROLS);
            self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurrentScrollViewContentHeight);
            self.mView.frame = CGRectMake(100.f, self.viewChooseMedia.frame.origin.y + CGRectGetHeight(self.viewChooseMedia.frame) + MARGIN_CONTROLS, fCameraCanvasViewWidth, 0);
            self.btnAddPhoto.frame = CGRectMake(iBtnAddPhotoOriginX, iBtnAddPhotoOriginY, CGRectGetWidth(self.btnAddPhoto.frame), CGRectGetHeight(self.btnAddPhoto.frame));
            self.btnPhoto.frame = CGRectMake(iBtnPhotoOriginX, iBtnPhotoOriginY, CGRectGetWidth(self.btnPhoto.frame), CGRectGetHeight(self.btnPhoto.frame));
            self.m_viewBottomMenu.frame = CGRectMake(50.f, fScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame), 668.f, CGRectGetHeight(self.m_viewBottomMenu.frame));
            
            return;
        }
        
        
    }
    
    //if no Text View
    self.btnAddPhoto.hidden = NO;
    self.btnPhoto.hidden = NO;
    
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        float fCurrentScrollViewContentHeight = fScrollViewContentHeight + (fCameraCanvasViewWidth + MARGIN_CONTROLS);
        self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurrentScrollViewContentHeight);
        self.mView.frame = CGRectMake(MARGIN_CANVAS, self.viewChooseMedia.frame.origin.y + CGRectGetHeight(self.viewChooseMedia.frame) + MARGIN_CONTROLS, fCameraCanvasViewWidth, fCameraCanvasViewWidth);
        self.btnAddPhoto.frame = CGRectMake(iBtnAddPhotoOriginX, iBtnAddPhotoOriginY + fCameraCanvasViewWidth, self.btnAddPhoto.frame.size.width, self.btnAddPhoto.frame.size.height);
        self.btnPhoto.frame = CGRectMake(iBtnPhotoOriginX, iBtnPhotoOriginY + fCameraCanvasViewWidth, self.btnPhoto.frame.size.width, self.btnPhoto.frame.size.height);
        self.mphotoView.frame = CGRectMake(iPhotoViewOriginX, iPhotoViewOriginY + (fCameraCanvasViewWidth + MARGIN_CONTROLS), fCameraCanvasViewWidth, 0.f);
        self.m_viewBottomMenu.frame = CGRectMake(0, fCurrentScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.m_viewBottomMenu.frame));
    }
    else if (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && ([UIScreen mainScreen].bounds.size.height == 1366 || [UIScreen mainScreen].bounds.size.width == 1366)))
    {
        float fCurrentScrollViewContentHeight = fScrollViewContentHeight + (fCameraCanvasViewWidth + MARGIN_CONTROLS);
        self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurrentScrollViewContentHeight);
        self.mView.frame = CGRectMake(228.f, self.viewChooseMedia.frame.origin.y + CGRectGetHeight(self.viewChooseMedia.frame) + MARGIN_CONTROLS + 200.f, fCameraCanvasViewWidth, fCameraCanvasViewWidth);
        self.btnAddPhoto.frame = CGRectMake(iBtnAddPhotoOriginX, iBtnAddPhotoOriginY + fCameraCanvasViewWidth, self.btnAddPhoto.frame.size.width, self.btnAddPhoto.frame.size.height);
        self.btnPhoto.frame = CGRectMake(iBtnPhotoOriginX, iBtnPhotoOriginY + fCameraCanvasViewWidth, self.btnPhoto.frame.size.width, self.btnPhoto.frame.size.height);
        self.mphotoView.frame = CGRectMake(228.f, iPhotoViewOriginY + (fCameraCanvasViewWidth + MARGIN_CONTROLS), fCameraCanvasViewWidth, 0.f);
        self.m_viewBottomMenu.frame = CGRectMake(178.f, fCurrentScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame) - 20.f, 668.f, CGRectGetHeight(self.m_viewBottomMenu.frame));
    }
    else
    {
        //[ipad]
        float fCurrentScrollViewContentHeight = fScrollViewContentHeight + (fCameraCanvasViewWidth + MARGIN_CONTROLS);
        self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurrentScrollViewContentHeight);
        self.mView.frame = CGRectMake(100.f, self.viewChooseMedia.frame.origin.y + CGRectGetHeight(self.viewChooseMedia.frame) + MARGIN_CONTROLS, fCameraCanvasViewWidth, fCameraCanvasViewWidth);
        self.btnAddPhoto.frame = CGRectMake(iBtnAddPhotoOriginX, iBtnAddPhotoOriginY + fCameraCanvasViewWidth, self.btnAddPhoto.frame.size.width, self.btnAddPhoto.frame.size.height);
        self.btnPhoto.frame = CGRectMake(iBtnPhotoOriginX, iBtnPhotoOriginY + fCameraCanvasViewWidth, self.btnPhoto.frame.size.width, self.btnPhoto.frame.size.height);
        self.mphotoView.frame = CGRectMake(100.f, iPhotoViewOriginY + (fCameraCanvasViewWidth + MARGIN_CONTROLS), fCameraCanvasViewWidth, 0.f);
        self.m_viewBottomMenu.frame = CGRectMake(50.f, fCurrentScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame) - 20.f, 668.f, CGRectGetHeight(self.m_viewBottomMenu.frame));
    }
    
    
    
    //locate Text View in mView.
    bAlreadyTextMedia = true;
    
    if(bAlreadyPhotoMedia)
    {
        if(eCurrentMediaType == PHOTO_MEDIA)
        {
            CustomCameraView* currentPhotoCameraView = (CustomCameraView *)[self.mphotoView viewWithTag:100];
            if (currentPhotoCameraView)
            {
                [currentPhotoCameraView unInitCameraView];
                [currentPhotoCameraView removeFromSuperview];
                currentPhotoCameraView = nil;
            }
        }
        else if (eCurrentMediaType == ADDITIONAL_PHOTO_MEDIA){
            
            CustomCameraView* currentAddPhotoCameraView = (CustomCameraView *)[self.mphotoView viewWithTag:101];
            if (currentAddPhotoCameraView)
            {
                [currentAddPhotoCameraView unInitCameraView];
                [currentAddPhotoCameraView removeFromSuperview];
                currentAddPhotoCameraView = nil;
            }
        }
        bAlreadyPhotoMedia = false;
        
    }
    
    eCurrentMediaType = TEXT_MEDIA;
    [self makeSelectedStatusForMedia];
    
    ReviewTextView* reviewTextView = [[[NSBundle mainBundle] loadNibNamed:@"ReviewTextView" owner:self options:nil] objectAtIndex:0];
    reviewTextView.frame = self.mView.bounds;
    reviewTextView.tag = 400;
    reviewTextView.m_txtView.text = strReviewText;
    [self.mView addSubview:reviewTextView];
    
}

- (IBAction)onClickAdditionalPhoto:(id)sender {
    
    if (bAlreadyPhotoMedia)
    {
        if(eCurrentMediaType == ADDITIONAL_PHOTO_MEDIA)
        {
            eCurrentMediaType = NONE_MEDIA;
            
            CustomCameraView* currentAddPhotoCameraView = (CustomCameraView *)[self.mphotoView viewWithTag:101];
            if (currentAddPhotoCameraView)
            {
                [currentAddPhotoCameraView unInitCameraView];
                [currentAddPhotoCameraView removeFromSuperview];
                currentAddPhotoCameraView = nil;
            }
            
            [self makeSelectedStatusForMedia];
            bAlreadyPhotoMedia = false;
            
            if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
            {
                //adjust position and size
                float fCurentScrollViewContentHeight = self.mScrollView.contentSize.height - (fCameraCanvasViewWidth + MARGIN_CONTROLS);
                self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurentScrollViewContentHeight);
                self.mphotoView.frame = CGRectMake(self.mphotoView.frame.origin.x, self.mphotoView.frame.origin.y, fCameraCanvasViewWidth, 0.f);
                self.m_viewBottomMenu.frame = CGRectMake(0, fCurentScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.m_viewBottomMenu.frame));
            }
            else if (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && ([UIScreen mainScreen].bounds.size.height == 1366 || [UIScreen mainScreen].bounds.size.width == 1366)))
            {
                float fCurentScrollViewContentHeight = self.mScrollView.contentSize.height - (fCameraCanvasViewWidth + MARGIN_CONTROLS);
                self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurentScrollViewContentHeight);
                self.mphotoView.frame = CGRectMake(228.f, self.mphotoView.frame.origin.y, fCameraCanvasViewWidth, 0.f);
                self.m_viewBottomMenu.frame = CGRectMake(178.f, fCurentScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame) - 20.f, 668.f, CGRectGetHeight(self.m_viewBottomMenu.frame));
            }
            else
            {
                //[ipad]
                //adjust position and size
                float fCurentScrollViewContentHeight = self.mScrollView.contentSize.height - (fCameraCanvasViewWidth + MARGIN_CONTROLS);
                self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurentScrollViewContentHeight);
                self.mphotoView.frame = CGRectMake(100.f, self.mphotoView.frame.origin.y, fCameraCanvasViewWidth, 0.f);
                self.m_viewBottomMenu.frame = CGRectMake(50.f, fCurentScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame) - 20.f, 668.f, CGRectGetHeight(self.m_viewBottomMenu.frame));
            }
            
            
            return;
        }
        else //ecurrentMediaType is photo_media
        {
            eCurrentMediaType = ADDITIONAL_PHOTO_MEDIA;
            
            CustomCameraView* currentPhotoCameraView = (CustomCameraView *)[self.mphotoView viewWithTag:100];
            if (currentPhotoCameraView)
            {
                [currentPhotoCameraView unInitCameraView];
                [currentPhotoCameraView removeFromSuperview];
                currentPhotoCameraView = nil;
            }
            
            CustomCameraView* photoCameraView = [[CustomCameraView alloc] initWithFrame:self.mphotoView.bounds];
            photoCameraView.eSelectedCameraType = PHOTO_CAMERA;
            photoCameraView.delegate = self;
            photoCameraView.tag = 101;
            [self.mphotoView addSubview:photoCameraView];
            [photoCameraView initCameraView];
            
            [self makeSelectedStatusForMedia];
            return;
        }
        
    }
    //if video view exist then remove it but not adjust
    CustomCameraView* currentVideoCameraView = (CustomCameraView *)[self.mView viewWithTag:200];
    if (currentVideoCameraView)
    {
        [currentVideoCameraView unInitCameraView];
        [currentVideoCameraView removeFromSuperview];
        currentVideoCameraView = nil;
    }
    bAlreadyVideoMedia = false;
    
    bAlreadyPhotoMedia = true;
    
    if (bAlreadyTextMedia || bAlreadyAudioMedia)
    {
        eCurrentMediaType = ADDITIONAL_PHOTO_MEDIA;
        [self makeSelectedStatusForMedia];
        
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
        {
            float fCurrentScrollViewContentHeight = fScrollViewContentHeight + 2 * (fCameraCanvasViewWidth + MARGIN_CONTROLS);
            self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurrentScrollViewContentHeight);
            self.m_viewBottomMenu.frame = CGRectMake(0, fCurrentScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.m_viewBottomMenu.frame));
            self.mphotoView.frame = CGRectMake(MARGIN_CANVAS, self.btnAddPhoto.frame.origin.y + self.btnAddPhoto.frame.size.height + MARGIN_CONTROLS, fCameraCanvasViewWidth, fCameraCanvasViewWidth);
        }
        else if (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && ([UIScreen mainScreen].bounds.size.height == 1366 || [UIScreen mainScreen].bounds.size.width == 1366)))
        {
            float fCurrentScrollViewContentHeight = fScrollViewContentHeight + 2 * (fCameraCanvasViewWidth + MARGIN_CONTROLS);
            self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurrentScrollViewContentHeight);
            self.m_viewBottomMenu.frame = CGRectMake(178.f, fCurrentScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame) - 20.f, 668.f, CGRectGetHeight(self.m_viewBottomMenu.frame));
            self.mphotoView.frame = CGRectMake(228.f, self.btnAddPhoto.frame.origin.y + self.btnAddPhoto.frame.size.height + MARGIN_CONTROLS, fCameraCanvasViewWidth, fCameraCanvasViewWidth);
        }
        else
        {
            //[ipad]
            float fCurrentScrollViewContentHeight = fScrollViewContentHeight + 2 * (fCameraCanvasViewWidth + MARGIN_CONTROLS);
            self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurrentScrollViewContentHeight);
            self.m_viewBottomMenu.frame = CGRectMake(50.f, fCurrentScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame) - 20.f, 668.f, CGRectGetHeight(self.m_viewBottomMenu.frame));
            self.mphotoView.frame = CGRectMake(100.f, self.btnAddPhoto.frame.origin.y + self.btnAddPhoto.frame.size.height + MARGIN_CONTROLS, fCameraCanvasViewWidth, fCameraCanvasViewWidth);
        }
        
    }
    else
    {
        eCurrentMediaType = ADDITIONAL_PHOTO_MEDIA;
        [self makeSelectedStatusForMedia];
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
        {
            float fCurrentScrollViewContentHeight = fScrollViewContentHeight + fCameraCanvasViewWidth + MARGIN_CONTROLS;
            self.mView.frame = CGRectMake(self.mView.frame.origin.x, self.mView.frame.origin.y, fCameraCanvasViewWidth, 0.f);
            self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurrentScrollViewContentHeight);
            self.m_viewBottomMenu.frame = CGRectMake(0, fCurrentScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.m_viewBottomMenu.frame));
            self.mphotoView.frame = CGRectMake(MARGIN_CANVAS, self.btnAddPhoto.frame.origin.y + CGRectGetHeight(self.btnAddPhoto.frame) + MARGIN_CONTROLS, fCameraCanvasViewWidth, fCameraCanvasViewWidth);
        }
        else if (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && ([UIScreen mainScreen].bounds.size.height == 1366 || [UIScreen mainScreen].bounds.size.width == 1366)))
        {
            float fCurrentScrollViewContentHeight = fScrollViewContentHeight + fCameraCanvasViewWidth + MARGIN_CONTROLS;
            self.mView.frame = CGRectMake(self.mView.frame.origin.x, self.mView.frame.origin.y, fCameraCanvasViewWidth, 0.f);
            self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurrentScrollViewContentHeight);
            self.m_viewBottomMenu.frame = CGRectMake(178.f, fCurrentScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame) - 20.f, 668.f, CGRectGetHeight(self.m_viewBottomMenu.frame));
            self.mphotoView.frame = CGRectMake(228.f, self.btnAddPhoto.frame.origin.y + CGRectGetHeight(self.btnAddPhoto.frame) + MARGIN_CONTROLS, fCameraCanvasViewWidth, fCameraCanvasViewWidth);
        }
        else
        {
            //[ipad]
            float fCurrentScrollViewContentHeight = fScrollViewContentHeight + fCameraCanvasViewWidth + MARGIN_CONTROLS;
            self.mView.frame = CGRectMake(self.mView.frame.origin.x, self.mView.frame.origin.y, fCameraCanvasViewWidth, 0.f);
            self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurrentScrollViewContentHeight);
            self.m_viewBottomMenu.frame = CGRectMake(50.f, fCurrentScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame) - 20.f, 668.f, CGRectGetHeight(self.m_viewBottomMenu.frame));
            self.mphotoView.frame = CGRectMake(100.f, self.btnAddPhoto.frame.origin.y + CGRectGetHeight(self.btnAddPhoto.frame) + MARGIN_CONTROLS, fCameraCanvasViewWidth, fCameraCanvasViewWidth);
        }
        
    }
    
    eCurrentMediaType = ADDITIONAL_PHOTO_MEDIA;
    
    CustomCameraView* photoCameraView = [[CustomCameraView alloc] initWithFrame:self.mphotoView.bounds];
    photoCameraView.eSelectedCameraType = PHOTO_CAMERA;
    photoCameraView.delegate = self;
    photoCameraView.tag = 101;
    [self.mphotoView addSubview:photoCameraView];
    [photoCameraView initCameraView];
    
}


- (IBAction)actionSubmit:(id)sender {
    
    //Get review text
    ReviewTextView* reviewTextView = (ReviewTextView *)[self.mView viewWithTag:400];
    if (reviewTextView)
    {
        strReviewText = reviewTextView.m_txtView.text;
        
    }
    
    //for rating value
    if ([rating intValue] == 0) {
        rating = [NSNumber numberWithInt:5];
    }
    
    //if
    //    if ([self.firstname_T.text isEqual:@""] || [self.lastname_T.text isEqual:@""]) {
    //        [self showWarningAlert:@"You didn't fill full name field!"];
    //        //return;
    //    }
    //
    //    if ([self.mailadr_T.text isEqual:@""]) {
    //
    //        [self showWarningAlert:@"You didn't fill E-mail address field!"];
    //
    //    }
    if (![self.mailadr_T.text isEqual:@""])
    {
        if (![self.mailadr_T.text isValidEmail])
        {
            [self showErrorAlert:@"Please input valid email address!"];
            return;
        }
        
    }
    if ([self.compname_T.text isEqual:@""] || [self.compcity_T.text isEqual:@""] || [self.compstate_T.text isEqual:@""]) {
        [self showErrorAlert:@"Please check your company information!"];
        return;
    }
    
    if (capturedVideoLink == nil && recordedAudioLink == nil && strReviewText.length == 0)
    {
        [self showErrorAlert:@"Please take media!"];
        return;
    }
    
    if (recordedAudioLink != nil && imgProofPurchasePhoto == nil && capturedVideoLink == nil)
    {
        [self showErrorAlert:@"Please take more photo!"];
        return;
    }
    
    //    if (recordedAudioLink != nil && imgAdditionalPhoto == nil)
    //    {
    //        [self showErrorAlert:@"Please take more photo"];
    //        return;
    //    }
    
    if (strReviewText.length != 0 && imgProofPurchasePhoto == nil && capturedVideoLink == nil)
    {
        [self showErrorAlert:@"Please take more photo"];
        return;
    }
    
    //    if (strReviewText.length != 0 && imgAdditionalPhoto == nil)
    //    {
    //        [self showErrorAlert:@"Please take more photo"];
    //        return;
    //    }
    
    if (!isAcceptTerms)
    {
        [self showAcceptTerms:@"Please agree Terms!"];
        return;
    }
    
    
    
    //submit api
    
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setObject:self.firstname_T.text forKey:@"first_name"];
    [dictParam setObject:self.lastname_T.text forKey:@"last_name"];
    [dictParam setObject:self.mailadr_T.text forKey:@"email"];
    [dictParam setObject:self.compname_T.text forKey:@"company_name"];
    [dictParam setObject:self.compcity_T.text forKey:@"company_city"];
    [dictParam setObject:self.compstate_T.text forKey:@"company_state"];
    [dictParam setObject:rating forKey:@"ratingvalue"];
    
    self.spinner.hidden = NO;
    [self.spinner startAnimating];
    if (capturedVideoLink != nil && scheduleType == 1) {
        
        NSData *videoData = [NSData dataWithContentsOfURL:capturedVideoLink];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:videoUploadUrl parameters:dictParam
constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFileData:videoData name:@"video" fileName:@"video.mov" mimeType:@"video/quicktime"];
    
}
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSLog(@"videoResponse: %@", responseObject);
                  [self.spinner stopAnimating];
                  self.spinner.hidden = YES;
                  [self showSuccessSubmitAlert:@"Submit Success!"];
                  return;
                  
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  NSLog(@"videoError: %@", error);
                  [self.spinner stopAnimating];
                  self.spinner.hidden = YES;
                  [self showFailureSubmitAlert:@"Submit Falied"];
                  return;
              }];
        
    }else if (recordedAudioLink !=nil && imgAdditionalPhoto !=nil && imgProofPurchasePhoto !=nil && scheduleType == 2){
        
        NSData *proofPhotoData = UIImageJPEGRepresentation(imgProofPurchasePhoto, 0.8);
        NSData *additionalPhotoData = UIImageJPEGRepresentation(imgAdditionalPhoto, 0.8);
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:audioUploadUrl parameters:dictParam
constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFileData:proofPhotoData name:@"proofphoto" fileName:@"proofphoto.jpg" mimeType:@"image/jpeg"];
    [formData appendPartWithFileData:additionalPhotoData name:@"additionalphoto" fileName:@"additionalphoto.jpg" mimeType:@"image/jpeg"];
    [formData appendPartWithFileURL:recordedAudioLink name:@"audio" fileName:@"audio.wav" mimeType:@"audio/wav" error:nil];
}
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSLog(@"audioResponse: %@", responseObject);
                  [self.spinner stopAnimating];
                  self.spinner.hidden = YES;
                  [self showSuccessSubmitAlert:@"Submit Success!"];
                  return;
                  
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  NSLog(@"audioError: %@", error);
                  [self.spinner stopAnimating];
                  self.spinner.hidden = YES;
                  [self showFailureSubmitAlert:@"Submit Falied"];
                  return;
              }];
        
    }else if (recordedAudioLink !=nil && imgAdditionalPhoto == nil && imgProofPurchasePhoto !=nil && scheduleType == 2){
        
        NSData *proofPhotoData = UIImageJPEGRepresentation(imgProofPurchasePhoto, 0.8);
        //NSData *additionalPhotoData = UIImageJPEGRepresentation(imgAdditionalPhoto, 0.8);
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:audioUploadUrl parameters:dictParam
constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFileData:proofPhotoData name:@"proofphoto" fileName:@"proofphoto.jpg" mimeType:@"image/jpeg"];
    //[formData appendPartWithFileData:additionalPhotoData name:@"additionalphoto" fileName:@"additionalphoto.jpg" mimeType:@"image/jpeg"];
    [formData appendPartWithFileURL:recordedAudioLink name:@"audio" fileName:@"audio.wav" mimeType:@"audio/wav" error:nil];
}
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSLog(@"audioResponse: %@", responseObject);
                  [self.spinner stopAnimating];
                  self.spinner.hidden = YES;
                  [self showSuccessSubmitAlert:@"Submit Success!"];
                  return;
                  
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  NSLog(@"audioError: %@", error);
                  [self.spinner stopAnimating];
                  self.spinner.hidden = YES;
                  [self showFailureSubmitAlert:@"Submit Falied"];
                  return;
              }];
        
    }else if (strReviewText != nil && imgAdditionalPhoto !=nil && imgProofPurchasePhoto !=nil && scheduleType == 3){
        
        NSMutableDictionary *dictParam3 =[[NSMutableDictionary alloc]init];
        [dictParam3 setObject:self.firstname_T.text forKey:@"first_name"];
        [dictParam3 setObject:self.lastname_T.text forKey:@"last_name"];
        [dictParam3 setObject:self.mailadr_T.text forKey:@"email"];
        [dictParam3 setObject:self.compname_T.text forKey:@"company_name"];
        [dictParam3 setObject:self.compcity_T.text forKey:@"company_city"];
        [dictParam3 setObject:self.compstate_T.text forKey:@"company_state"];
        [dictParam3 setObject:rating forKey:@"ratingvalue"];
        
        [dictParam3 setObject:strReviewText forKey:@"reviewtext"];
        NSData *proofPhotoData = UIImageJPEGRepresentation(imgProofPurchasePhoto, 0.8);
        NSData *additionalPhotoData = UIImageJPEGRepresentation(imgAdditionalPhoto, 0.8);
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager POST:textUploadUrl parameters:dictParam3
constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFileData:proofPhotoData name:@"proofphoto" fileName:@"proofphoto.jpg" mimeType:@"image/jpeg"];
    [formData appendPartWithFileData:additionalPhotoData name:@"additionalphoto" fileName:@"additionalphoto.jpg" mimeType:@"image/jpeg"];
}
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSLog(@"textResponse: %@", responseObject);
                  [self.spinner stopAnimating];
                  self.spinner.hidden = YES;
                  [self showSuccessSubmitAlert:@"Submit Success!"];
                  return;
                  
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  NSLog(@"textError: %@", error);
                  [self.spinner stopAnimating];
                  self.spinner.hidden = YES;
                  [self showFailureSubmitAlert:@"Submit Falied"];
                  return;
              }];
    }else if (strReviewText != nil && imgAdditionalPhoto == nil && imgProofPurchasePhoto !=nil && scheduleType == 3){
        
        NSMutableDictionary *dictParam3 =[[NSMutableDictionary alloc]init];
        [dictParam3 setObject:self.firstname_T.text forKey:@"first_name"];
        [dictParam3 setObject:self.lastname_T.text forKey:@"last_name"];
        [dictParam3 setObject:self.mailadr_T.text forKey:@"email"];
        [dictParam3 setObject:self.compname_T.text forKey:@"company_name"];
        [dictParam3 setObject:self.compcity_T.text forKey:@"company_city"];
        [dictParam3 setObject:self.compstate_T.text forKey:@"company_state"];
        [dictParam3 setObject:rating forKey:@"ratingvalue"];
        
        [dictParam3 setObject:strReviewText forKey:@"reviewtext"];
        NSData *proofPhotoData = UIImageJPEGRepresentation(imgProofPurchasePhoto, 0.8);
        //NSData *additionalPhotoData = UIImageJPEGRepresentation(imgAdditionalPhoto, 0.8);
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager POST:textUploadUrl parameters:dictParam3
constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFileData:proofPhotoData name:@"proofphoto" fileName:@"proofphoto.jpg" mimeType:@"image/jpeg"];
    //[formData appendPartWithFileData:additionalPhotoData name:@"additionalphoto" fileName:@"additionalphoto.jpg" mimeType:@"image/jpeg"];
}
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSLog(@"textResponse: %@", responseObject);
                  [self.spinner stopAnimating];
                  self.spinner.hidden = YES;
                  [self showSuccessSubmitAlert:@"Submit Success!"];
                  return;
                  
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  NSLog(@"textError: %@", error);
                  [self.spinner stopAnimating];
                  self.spinner.hidden = YES;
                  [self showFailureSubmitAlert:@"Submit Falied"];
                  return;
              }];
    }
    
    //after submission
    
    [self initAllMediaValues];
    reviewTextView.m_txtView.text = @"";
    [self onchkBtn:self];
    
    //position and size adjustment
    if(scheduleType == 2)
    {
        RecordAudioView* recordAudioView = (RecordAudioView *)[self.mView viewWithTag:300];
        if (recordAudioView)
        {
            [recordAudioView removeFromSuperview];
            recordAudioView = nil;
        }
        
        bAlreadyAudioMedia = false;
        
        //if exist photoview then remove it and adjust position
        if(bAlreadyPhotoMedia)
        {
            if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
            {
                //iPhone
                //remove photo view and adjust position.
                float fCurrentScrollViewContentHeight = self.mScrollView.contentSize.height -  2 * fCameraCanvasViewWidth - MARGIN_CONTROLS;
                self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurrentScrollViewContentHeight);
                self.btnAddPhoto.frame = CGRectMake(iBtnAddPhotoOriginX, iBtnAddPhotoOriginY, CGRectGetWidth(self.btnAddPhoto.frame), CGRectGetHeight(self.btnAddPhoto.frame));
                self.btnPhoto.frame = CGRectMake(iBtnPhotoOriginX, iBtnPhotoOriginY, CGRectGetWidth(self.btnPhoto.frame), CGRectGetHeight(self.btnPhoto.frame));
                self.mphotoView.frame = CGRectMake(iPhotoViewOriginX, iPhotoViewOriginY, fCameraCanvasViewWidth, 0.f);
                self.m_viewBottomMenu.frame = CGRectMake(0, fScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.m_viewBottomMenu.frame));
                self.mView.frame = CGRectMake(MARGIN_CANVAS, self.viewChooseMedia.frame.origin.y + CGRectGetHeight(self.viewChooseMedia.frame) + MARGIN_CONTROLS, fCameraCanvasViewWidth, 0);
            }
            else if (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && ([UIScreen mainScreen].bounds.size.height == 1366 || [UIScreen mainScreen].bounds.size.width == 1366)))
            {
                float fCurrentScrollViewContentHeight = self.mScrollView.contentSize.height -  2 * fCameraCanvasViewWidth - MARGIN_CONTROLS;
                self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurrentScrollViewContentHeight);
                self.btnAddPhoto.frame = CGRectMake(iBtnAddPhotoOriginX, iBtnAddPhotoOriginY, CGRectGetWidth(self.btnAddPhoto.frame), CGRectGetHeight(self.btnAddPhoto.frame));
                self.btnPhoto.frame = CGRectMake(iBtnPhotoOriginX, iBtnPhotoOriginY, CGRectGetWidth(self.btnPhoto.frame), CGRectGetHeight(self.btnPhoto.frame));
                self.mphotoView.frame = CGRectMake(228.f, iPhotoViewOriginY, fCameraCanvasViewWidth, 0.f);
                self.m_viewBottomMenu.frame = CGRectMake(178.f, fScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame), 668.f, CGRectGetHeight(self.m_viewBottomMenu.frame));
                self.mView.frame = CGRectMake(228.f, self.viewChooseMedia.frame.origin.y + CGRectGetHeight(self.viewChooseMedia.frame) + MARGIN_CONTROLS, fCameraCanvasViewWidth, 0);
            }
            else
            {
                //[ipad]
                //remove photo view and adjust position.
                float fCurrentScrollViewContentHeight = self.mScrollView.contentSize.height -  2 * fCameraCanvasViewWidth - MARGIN_CONTROLS;
                self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurrentScrollViewContentHeight);
                self.btnAddPhoto.frame = CGRectMake(iBtnAddPhotoOriginX, iBtnAddPhotoOriginY, CGRectGetWidth(self.btnAddPhoto.frame), CGRectGetHeight(self.btnAddPhoto.frame));
                self.btnPhoto.frame = CGRectMake(iBtnPhotoOriginX, iBtnPhotoOriginY, CGRectGetWidth(self.btnPhoto.frame), CGRectGetHeight(self.btnPhoto.frame));
                self.mphotoView.frame = CGRectMake(100.f, iPhotoViewOriginY, fCameraCanvasViewWidth, 0.f);
                self.m_viewBottomMenu.frame = CGRectMake(50.f, fScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame), 668.f, CGRectGetHeight(self.m_viewBottomMenu.frame));
                self.mView.frame = CGRectMake(100.f, self.viewChooseMedia.frame.origin.y + CGRectGetHeight(self.viewChooseMedia.frame) + MARGIN_CONTROLS, fCameraCanvasViewWidth, 0);
            }
            
            
            if(eCurrentMediaType == PHOTO_MEDIA)
            {
                CustomCameraView* currentPhotoCameraView = (CustomCameraView *)[self.mphotoView viewWithTag:100];
                if (currentPhotoCameraView)
                {
                    [currentPhotoCameraView unInitCameraView];
                    [currentPhotoCameraView removeFromSuperview];
                    currentPhotoCameraView = nil;
                }
            }
            else if (eCurrentMediaType == ADDITIONAL_PHOTO_MEDIA){
                
                CustomCameraView* currentAddPhotoCameraView = (CustomCameraView *)[self.mphotoView viewWithTag:101];
                if (currentAddPhotoCameraView)
                {
                    [currentAddPhotoCameraView unInitCameraView];
                    [currentAddPhotoCameraView removeFromSuperview];
                    currentAddPhotoCameraView = nil;
                }
            }
            
            eCurrentMediaType = NONE_MEDIA;
            [self makeSelectedStatusForMedia];
            bAlreadyPhotoMedia = false;
            return;
        }
        
        eCurrentMediaType = NONE_MEDIA;
        [self makeSelectedStatusForMedia];
        
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
        {
            //iPhone
            float fCurrentScrollViewContentHeight = self.mScrollView.contentSize.height - (fCameraCanvasViewWidth + MARGIN_CONTROLS);
            self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurrentScrollViewContentHeight);
            self.mView.frame = CGRectMake(MARGIN_CANVAS, self.viewChooseMedia.frame.origin.y + CGRectGetHeight(self.viewChooseMedia.frame) + MARGIN_CONTROLS, fCameraCanvasViewWidth, 0);
            self.btnAddPhoto.frame = CGRectMake(iBtnAddPhotoOriginX, iBtnAddPhotoOriginY, CGRectGetWidth(self.btnAddPhoto.frame), CGRectGetHeight(self.btnAddPhoto.frame));
            self.btnPhoto.frame = CGRectMake(iBtnPhotoOriginX, iBtnPhotoOriginY, CGRectGetWidth(self.btnPhoto.frame), CGRectGetHeight(self.btnPhoto.frame));
            self.m_viewBottomMenu.frame = CGRectMake(0, fScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.m_viewBottomMenu.frame));
            
            return;
        }
        else if (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && ([UIScreen mainScreen].bounds.size.height == 1366 || [UIScreen mainScreen].bounds.size.width == 1366)))
        {
            float fCurrentScrollViewContentHeight = self.mScrollView.contentSize.height - (fCameraCanvasViewWidth + MARGIN_CONTROLS);
            self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurrentScrollViewContentHeight);
            self.mView.frame = CGRectMake(100.f, self.viewChooseMedia.frame.origin.y + CGRectGetHeight(self.viewChooseMedia.frame) + MARGIN_CONTROLS, fCameraCanvasViewWidth, 0);
            self.btnAddPhoto.frame = CGRectMake(iBtnAddPhotoOriginX, iBtnAddPhotoOriginY, CGRectGetWidth(self.btnAddPhoto.frame), CGRectGetHeight(self.btnAddPhoto.frame));
            self.btnPhoto.frame = CGRectMake(iBtnPhotoOriginX, iBtnPhotoOriginY, CGRectGetWidth(self.btnPhoto.frame), CGRectGetHeight(self.btnPhoto.frame));
            self.m_viewBottomMenu.frame = CGRectMake(178.f, fScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame), 668.f, CGRectGetHeight(self.m_viewBottomMenu.frame));
            
            return;
        }
        else
        {
            //[ipad]
            float fCurrentScrollViewContentHeight = self.mScrollView.contentSize.height - (fCameraCanvasViewWidth + MARGIN_CONTROLS);
            self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurrentScrollViewContentHeight);
            self.mView.frame = CGRectMake(100.f, self.viewChooseMedia.frame.origin.y + CGRectGetHeight(self.viewChooseMedia.frame) + MARGIN_CONTROLS, fCameraCanvasViewWidth, 0);
            self.btnAddPhoto.frame = CGRectMake(iBtnAddPhotoOriginX, iBtnAddPhotoOriginY, CGRectGetWidth(self.btnAddPhoto.frame), CGRectGetHeight(self.btnAddPhoto.frame));
            self.btnPhoto.frame = CGRectMake(iBtnPhotoOriginX, iBtnPhotoOriginY, CGRectGetWidth(self.btnPhoto.frame), CGRectGetHeight(self.btnPhoto.frame));
            self.m_viewBottomMenu.frame = CGRectMake(50.f, fScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame), 668.f, CGRectGetHeight(self.m_viewBottomMenu.frame));
            
            return;
        }
    }
    else if(scheduleType == 1)
    {
        eCurrentMediaType = NONE_MEDIA;
        [self makeSelectedStatusForMedia];
        bAlreadyVideoMedia = false;
        
        CustomCameraView* currentVideoCameraView = (CustomCameraView *)[self.mView viewWithTag:200];
        if (currentVideoCameraView)
        {
            [currentVideoCameraView unInitCameraView];
            [currentVideoCameraView removeFromSuperview];
            currentVideoCameraView = nil;
        }
        
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
        {
            float fCurentScrollViewContentHeight = self.mScrollView.contentSize.height - (fCameraCanvasViewWidth + MARGIN_CONTROLS);
            self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurentScrollViewContentHeight);
            self.btnAddPhoto.frame = CGRectMake(iBtnAddPhotoOriginX, iBtnAddPhotoOriginY, self.btnAddPhoto.frame.size.width, self.btnAddPhoto.frame.size.height);
            self.btnPhoto.frame = CGRectMake(iBtnPhotoOriginX, iBtnPhotoOriginY, self.btnPhoto.frame.size.width, self.btnPhoto.frame.size.height);
            self.m_viewBottomMenu.frame = CGRectMake(0, fCurentScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.m_viewBottomMenu.frame));
            self.mView.frame = CGRectMake(imViewOriginX, imViewOriginY, fCameraCanvasViewWidth, 0.f);
            
            return;
        }
        else if (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && ([UIScreen mainScreen].bounds.size.height == 1366 || [UIScreen mainScreen].bounds.size.width == 1366)))
        {
            float fCurentScrollViewContentHeight = self.mScrollView.contentSize.height - (fCameraCanvasViewWidth + MARGIN_CONTROLS);
            self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurentScrollViewContentHeight);
            self.btnAddPhoto.frame = CGRectMake(iBtnAddPhotoOriginX, iBtnAddPhotoOriginY, self.btnAddPhoto.frame.size.width, self.btnAddPhoto.frame.size.height);
            self.btnPhoto.frame = CGRectMake(iBtnPhotoOriginX, iBtnPhotoOriginY, self.btnPhoto.frame.size.width, self.btnPhoto.frame.size.height);
            self.m_viewBottomMenu.frame = CGRectMake(178.f, fCurentScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame) - 20.f, 668.f, CGRectGetHeight(self.m_viewBottomMenu.frame));
            self.mView.frame = CGRectMake(228.f, imViewOriginY, fCameraCanvasViewWidth, 0.f);
            
            return;
        }
        else
        {
            //[ipad]
            float fCurentScrollViewContentHeight = self.mScrollView.contentSize.height - (fCameraCanvasViewWidth + MARGIN_CONTROLS);
            self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurentScrollViewContentHeight);
            self.btnAddPhoto.frame = CGRectMake(iBtnAddPhotoOriginX, iBtnAddPhotoOriginY, self.btnAddPhoto.frame.size.width, self.btnAddPhoto.frame.size.height);
            self.btnPhoto.frame = CGRectMake(iBtnPhotoOriginX, iBtnPhotoOriginY, self.btnPhoto.frame.size.width, self.btnPhoto.frame.size.height);
            self.m_viewBottomMenu.frame = CGRectMake(50.f, fCurentScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame) - 20.f, 668.f, CGRectGetHeight(self.m_viewBottomMenu.frame));
            self.mView.frame = CGRectMake(100.f, imViewOriginY, fCameraCanvasViewWidth, 0.f);
            
            return;
        }
    }
    else if(scheduleType == 3)
    {
        ReviewTextView* reviewTextView = (ReviewTextView *)[self.mView viewWithTag:400];
        if (reviewTextView)
        {
            strReviewText = reviewTextView.m_txtView.text;
            [reviewTextView removeFromSuperview];
            reviewTextView = nil;
        }
        
        bAlreadyTextMedia = false;
        
        //if exist photoview then remove it and adjust position
        if(bAlreadyPhotoMedia)
        {
            //remove photo view and adjust position.
            if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
            {
                float fCurrentScrollViewContentHeight = self.mScrollView.contentSize.height -  2 * fCameraCanvasViewWidth - MARGIN_CONTROLS;
                self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurrentScrollViewContentHeight);
                self.btnAddPhoto.frame = CGRectMake(iBtnAddPhotoOriginX, iBtnAddPhotoOriginY, CGRectGetWidth(self.btnAddPhoto.frame), CGRectGetHeight(self.btnAddPhoto.frame));
                self.btnPhoto.frame = CGRectMake(iBtnPhotoOriginX, iBtnPhotoOriginY, CGRectGetWidth(self.btnPhoto.frame), CGRectGetHeight(self.btnPhoto.frame));
                self.mphotoView.frame = CGRectMake(iPhotoViewOriginX, iPhotoViewOriginY, fCameraCanvasViewWidth, 0.f);
                self.m_viewBottomMenu.frame = CGRectMake(0, fScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.m_viewBottomMenu.frame));
                self.mView.frame = CGRectMake(MARGIN_CANVAS, self.viewChooseMedia.frame.origin.y + CGRectGetHeight(self.viewChooseMedia.frame) + MARGIN_CONTROLS, fCameraCanvasViewWidth, 0);
            }
            else if (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && ([UIScreen mainScreen].bounds.size.height == 1366 || [UIScreen mainScreen].bounds.size.width == 1366)))
            {
                float fCurrentScrollViewContentHeight = self.mScrollView.contentSize.height -  2 * fCameraCanvasViewWidth - MARGIN_CONTROLS;
                self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurrentScrollViewContentHeight);
                self.btnAddPhoto.frame = CGRectMake(iBtnAddPhotoOriginX, iBtnAddPhotoOriginY, CGRectGetWidth(self.btnAddPhoto.frame), CGRectGetHeight(self.btnAddPhoto.frame));
                self.btnPhoto.frame = CGRectMake(iBtnPhotoOriginX, iBtnPhotoOriginY, CGRectGetWidth(self.btnPhoto.frame), CGRectGetHeight(self.btnPhoto.frame));
                self.mphotoView.frame = CGRectMake(228.f, iPhotoViewOriginY, fCameraCanvasViewWidth, 0.f);
                self.m_viewBottomMenu.frame = CGRectMake(178.f, fScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame), 668.f, CGRectGetHeight(self.m_viewBottomMenu.frame));
                self.mView.frame = CGRectMake(228.f, self.viewChooseMedia.frame.origin.y + CGRectGetHeight(self.viewChooseMedia.frame) + MARGIN_CONTROLS, fCameraCanvasViewWidth, 0);
            }
            else
            {
                //[ipad]
                float fCurrentScrollViewContentHeight = self.mScrollView.contentSize.height -  2 * fCameraCanvasViewWidth - MARGIN_CONTROLS;
                self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurrentScrollViewContentHeight);
                self.btnAddPhoto.frame = CGRectMake(iBtnAddPhotoOriginX, iBtnAddPhotoOriginY, CGRectGetWidth(self.btnAddPhoto.frame), CGRectGetHeight(self.btnAddPhoto.frame));
                self.btnPhoto.frame = CGRectMake(iBtnPhotoOriginX, iBtnPhotoOriginY, CGRectGetWidth(self.btnPhoto.frame), CGRectGetHeight(self.btnPhoto.frame));
                self.mphotoView.frame = CGRectMake(iPhotoViewOriginX, iPhotoViewOriginY, fCameraCanvasViewWidth, 0.f);
                self.m_viewBottomMenu.frame = CGRectMake(50.f, fScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame), 668.f, CGRectGetHeight(self.m_viewBottomMenu.frame));
                self.mView.frame = CGRectMake(100.f, self.viewChooseMedia.frame.origin.y + CGRectGetHeight(self.viewChooseMedia.frame) + MARGIN_CONTROLS, fCameraCanvasViewWidth, 0);
            }
            
            
            
            if(eCurrentMediaType == PHOTO_MEDIA)
            {
                CustomCameraView* currentPhotoCameraView = (CustomCameraView *)[self.mphotoView viewWithTag:100];
                if (currentPhotoCameraView)
                {
                    [currentPhotoCameraView unInitCameraView];
                    [currentPhotoCameraView removeFromSuperview];
                    currentPhotoCameraView = nil;
                }
            }
            else if (eCurrentMediaType == ADDITIONAL_PHOTO_MEDIA){
                
                CustomCameraView* currentAddPhotoCameraView = (CustomCameraView *)[self.mphotoView viewWithTag:101];
                if (currentAddPhotoCameraView)
                {
                    [currentAddPhotoCameraView unInitCameraView];
                    [currentAddPhotoCameraView removeFromSuperview];
                    currentAddPhotoCameraView = nil;
                }
            }
            
            eCurrentMediaType = NONE_MEDIA;
            [self makeSelectedStatusForMedia];
            
            bAlreadyPhotoMedia = false;
            return;
            
        }
        
        eCurrentMediaType = NONE_MEDIA;
        [self makeSelectedStatusForMedia];
        
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
        {
            float fCurrentScrollViewContentHeight = self.mScrollView.contentSize.height - (fCameraCanvasViewWidth + MARGIN_CONTROLS);
            self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurrentScrollViewContentHeight);
            self.mView.frame = CGRectMake(MARGIN_CANVAS, self.viewChooseMedia.frame.origin.y + CGRectGetHeight(self.viewChooseMedia.frame) + MARGIN_CONTROLS, fCameraCanvasViewWidth, 0);
            self.btnAddPhoto.frame = CGRectMake(iBtnAddPhotoOriginX, iBtnAddPhotoOriginY, CGRectGetWidth(self.btnAddPhoto.frame), CGRectGetHeight(self.btnAddPhoto.frame));
            self.btnPhoto.frame = CGRectMake(iBtnPhotoOriginX, iBtnPhotoOriginY, CGRectGetWidth(self.btnPhoto.frame), CGRectGetHeight(self.btnPhoto.frame));
            self.m_viewBottomMenu.frame = CGRectMake(0, fScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.m_viewBottomMenu.frame));
            
            return;
        }
        else if (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && ([UIScreen mainScreen].bounds.size.height == 1366 || [UIScreen mainScreen].bounds.size.width == 1366)))
        {
            float fCurrentScrollViewContentHeight = self.mScrollView.contentSize.height - (fCameraCanvasViewWidth + MARGIN_CONTROLS);
            self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurrentScrollViewContentHeight);
            self.mView.frame = CGRectMake(100.f, self.viewChooseMedia.frame.origin.y + CGRectGetHeight(self.viewChooseMedia.frame) + MARGIN_CONTROLS, fCameraCanvasViewWidth, 0);
            self.btnAddPhoto.frame = CGRectMake(iBtnAddPhotoOriginX, iBtnAddPhotoOriginY, CGRectGetWidth(self.btnAddPhoto.frame), CGRectGetHeight(self.btnAddPhoto.frame));
            self.btnPhoto.frame = CGRectMake(iBtnPhotoOriginX, iBtnPhotoOriginY, CGRectGetWidth(self.btnPhoto.frame), CGRectGetHeight(self.btnPhoto.frame));
            self.m_viewBottomMenu.frame = CGRectMake(178.f, fScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame), 668.f, CGRectGetHeight(self.m_viewBottomMenu.frame));
            
            return;
        }
        else
        {
            //[ipad]
            float fCurrentScrollViewContentHeight = self.mScrollView.contentSize.height - (fCameraCanvasViewWidth + MARGIN_CONTROLS);
            self.mScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fCurrentScrollViewContentHeight);
            self.mView.frame = CGRectMake(100.f, self.viewChooseMedia.frame.origin.y + CGRectGetHeight(self.viewChooseMedia.frame) + MARGIN_CONTROLS, fCameraCanvasViewWidth, 0);
            self.btnAddPhoto.frame = CGRectMake(iBtnAddPhotoOriginX, iBtnAddPhotoOriginY, CGRectGetWidth(self.btnAddPhoto.frame), CGRectGetHeight(self.btnAddPhoto.frame));
            self.btnPhoto.frame = CGRectMake(iBtnPhotoOriginX, iBtnPhotoOriginY, CGRectGetWidth(self.btnPhoto.frame), CGRectGetHeight(self.btnPhoto.frame));
            self.m_viewBottomMenu.frame = CGRectMake(50.f, fScrollViewContentHeight - CGRectGetHeight(self.m_viewBottomMenu.frame), 668.f, CGRectGetHeight(self.m_viewBottomMenu.frame));
            
            return;
        }
    }
    
}

- (void) showWarningAlert:(NSString *) strAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:strAlert delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}
- (void) showErrorAlert:(NSString *) strAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:strAlert delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}
- (void) showSuccessSubmitAlert:(NSString *) strAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:strAlert delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}
- (void) showFailureSubmitAlert:(NSString *) strAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure" message:strAlert delegate:self cancelButtonTitle:@"Try Again" otherButtonTitles: nil];
    [alert show];
}
- (void) showAcceptTerms:(NSString *) strAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Agree Terms" message:strAlert delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

#pragma mark Delegates
- (void) tookPhoto:(UIImage *)image
{
    NSLog(@"got image");
    if (eCurrentMediaType == PHOTO_MEDIA)
    {
        //photo media
        imgProofPurchasePhoto = image;
    } else if (eCurrentMediaType == ADDITIONAL_PHOTO_MEDIA)
    {
        //additional photo
        imgAdditionalPhoto = image;
    }
}

- (void) tookVideo:(NSURL *)videoLink
{
    //got video
    capturedVideoLink = videoLink;
}

- (void) recordedAudio:(NSURL *)audioLink
{
    //got audio
    recordedAudioLink = audioLink;
    
    
}

@end