//
//  CustomCameraView.h
//  Global_Review_Center
//
//  Created by Admin on 1/27/16.
//  Copyright © 2016 Oleg. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIImage+fixOrientation.h"
#import "PBJStrobeView.h"
#import "PBJFocusView.h"

#import "PBJVision.h"
#import "PBJVisionUtilities.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <GLKit/GLKit.h>

#import "ExtendedHitButton.h"

#import "CheckCaptureImageView.h"
#import "CheckCaptureVideoView.h"

@protocol CustomCameraViewDelegate;

typedef enum : NSUInteger {
    PHOTO_CAMERA = 100,
    VIDEO_CAMERA
} CAMERA_TYPE;

static void *CameraTorchModeObservationContext     = &CameraTorchModeObservationContext;

@interface CustomCameraView : UIView<UIGestureRecognizerDelegate, PBJVisionDelegate, CheckCaptureImageViewDelegate, CheckCaptureVideoViewDelegate>
{
    UIButton *_doneButton;
    UIButton *_flipButton;
    UIButton *_onionButton;
    UIView *_captureDock;
    UIView* viewCaptureButton;
    
    UILabel* _lblStatus;
    
    UIImage* captureImage;
    NSURL* captureVideoLink;
    
    //camera
    AVCaptureVideoPreviewLayer *_previewLayer;
    PBJFocusView *_focusView;
    
    UIView *_gestureView;
    UIView* _previewView;
    
    UILongPressGestureRecognizer *_longPressGestureRecognizer;
    UITapGestureRecognizer *_TapGestureRecognizer;
    UILongPressGestureRecognizer *_longPressGestureRecognizerForPhoto;
    UITapGestureRecognizer *_focusTapGestureRecognizer;
    UITapGestureRecognizer *_photoTapGestureRecognizer;
    
    GLKViewController *_effectsViewController;
    
    BOOL _recording;
    BOOL _switchForRecord;
    
    ALAssetsLibrary *_assetLibrary;
    __block NSDictionary *_currentVideo;
    __block NSDictionary *_currentPhoto;
}

@property (nonatomic, assign) CAMERA_TYPE eSelectedCameraType;

@property (nonatomic, weak) id<CustomCameraViewDelegate> delegate;

- (void) initCameraView;
- (void) unInitCameraView;

@end

@protocol CustomCameraViewDelegate <NSObject>

- (void) tookPhoto:(UIImage *) image;
- (void) tookVideo:(NSURL *) videoLink;

@end