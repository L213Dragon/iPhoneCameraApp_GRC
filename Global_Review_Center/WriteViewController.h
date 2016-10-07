//
//  WriteViewController.h
//  Global_Review_Center
//
//  Created by Uri Fedorenko on 1/19/16.
//  Copyright © 2016 Oleg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomCameraView.h"
#import "ReviewTextView.h"
#import "RecordAudioView.h"
#import "AFNetworking.h"
typedef enum : NSUInteger {
    NONE_MEDIA  = -1,
    PHOTO_MEDIA = 0,
    ADDITIONAL_PHOTO_MEDIA,
    VIDEO_MEDIA,
    AUDIO_MEDIA,
    TEXT_MEDIA
} MEDIA_TYPE;

#define videoUploadUrl   @"http://app.globalreviewcenter.com/videoupload.php"
#define audioUploadUrl   @"http://app.globalreviewcenter.com/audioupload.php"
#define textUploadUrl    @"http://app.globalreviewcenter.com/textupload.php"

@interface WriteViewController : UIViewController<UIGestureRecognizerDelegate, UIScrollViewDelegate>
{
    bool bAlreadyPhotoMedia;
    bool bAlreadyVideoMedia;
    bool bAlreadyAudioMedia;
    bool bAlreadyTextMedia;
    
    MEDIA_TYPE eCurrentMediaType;
    
    float fOriginMenuViewPosY;
    float fScrollViewContentHeight;
    float fCameraCanvasViewWidth;
    float scheduleType;
    
    CGRect ori_mView_rect;
    CGSize init_mScroll_cntSize;
    CGRect ori_mPhoto_rect;
    
    //selected multimedia
    UIImage* imgProofPurchasePhoto;
    UIImage* imgAdditionalPhoto;
    NSURL* capturedVideoLink;
    NSURL* recordedAudioLink;
    NSString* strReviewText;
}

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UILabel *mtitleLabel;
@property (weak, nonatomic) IBOutlet UIView *mseparatView;
@property (retain, nonatomic) IBOutlet UIScrollView *mScrollView;
@property (weak, nonatomic) IBOutlet UIView *mView;
@property (weak, nonatomic) IBOutlet UIButton *btnVideo;
@property (weak, nonatomic) IBOutlet UILabel *personalInf_L;
@property (weak, nonatomic) IBOutlet UITextField *firstname_T;
@property (weak, nonatomic) IBOutlet UITextField *lastname_T;
@property (weak, nonatomic) IBOutlet UITextField *mailadr_T;
@property (weak, nonatomic) IBOutlet UILabel *compInf_L;
@property (weak, nonatomic) IBOutlet UITextField *compname_T;
@property (weak, nonatomic) IBOutlet UITextField *compcity_T;
@property (weak, nonatomic) IBOutlet UITextField *compstate_T;
@property (weak, nonatomic) IBOutlet UIButton *btnPhoto;
@property (weak, nonatomic) IBOutlet UIButton *btnAudio;
@property (weak, nonatomic) IBOutlet UIButton *btnText;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;
@property (weak, nonatomic) IBOutlet UIView *mphotoView;
@property (weak, nonatomic) IBOutlet UIButton *chkBtn;
@property (weak, nonatomic) IBOutlet UILabel *noticeLabel;
@property (weak, nonatomic) IBOutlet UIView *viewChooseMedia;
@property (weak, nonatomic) IBOutlet UIView *m_viewBottomMenu;
@property (weak, nonatomic) IBOutlet UIButton *btnAddPhoto;

- (IBAction)onchkBtn:(id)sender;
- (IBAction)onClickVideo:(id)sender;
- (IBAction)onClickPhoto:(id)sender;
- (IBAction)onClickAudio:(id)sender;
- (IBAction)onClickText:(id)sender;
- (IBAction)onClickAdditionalPhoto:(id)sender;
- (IBAction)actionSubmit:(id)sender;

@end
