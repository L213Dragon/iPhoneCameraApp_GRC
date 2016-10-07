//
//  CustomCameraView.m
//  Global_Review_Center
//
//  Created by Admin on 1/27/16.
//  Copyright © 2016 Oleg. All rights reserved.
//

#import "CustomCameraView.h"

@implementation CustomCameraView

@synthesize eSelectedCameraType;

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
*/

- (void) initCameraView
{
    _assetLibrary = [[ALAssetsLibrary alloc] init];
    _switchForRecord = false;
    
    _previewView = [[UIView alloc] initWithFrame:self.bounds];
    
    _previewLayer = [[PBJVision sharedInstance] previewLayer];
    _previewLayer.frame = _previewView.bounds;
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [_previewView.layer addSublayer:_previewLayer];
    
    
    // onion skin
    _effectsViewController = [[GLKViewController alloc] init];
    _effectsViewController.preferredFramesPerSecond = 60;
    
    GLKView *view = (GLKView *)_effectsViewController.view;
    CGRect viewFrame = _previewView.bounds;
    view.frame = viewFrame;
    view.context = [[PBJVision sharedInstance] context];
    view.contentScaleFactor = [[UIScreen mainScreen] scale];
    view.alpha = 0.5f;
    view.hidden = YES;
    
    // focus view
    _focusView = [[PBJFocusView alloc] initWithFrame:CGRectZero];
    
    // touch to record
    _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_handleLongPressGestureRecognizer:)];
    _TapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleSingleTap:)];
    _longPressGestureRecognizer.delegate = self;
    _longPressGestureRecognizer.minimumPressDuration = 0.05f;
    _longPressGestureRecognizer.allowableMovement = 10.0f;
    
    _longPressGestureRecognizerForPhoto = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_handleLongPressGestureRecognizerForPhoto:)];
    _longPressGestureRecognizerForPhoto.delegate = self;
    _longPressGestureRecognizerForPhoto.minimumPressDuration = 0.05f;
    _longPressGestureRecognizerForPhoto.allowableMovement = 10.0f;
    
    // tap to focus
    _focusTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleFocusTapGesterRecognizer:)];
    _focusTapGestureRecognizer.delegate = self;
    _focusTapGestureRecognizer.numberOfTapsRequired = 1;
    _focusTapGestureRecognizer.enabled = YES;
    [_previewView addGestureRecognizer:_focusTapGestureRecognizer];
    
    // gesture view to record
    float fCaptureButtonHeight = 80.f;
    
    float fCaptureButtonY = CGRectGetHeight(self.frame) - 88.f;
    
    viewCaptureButton = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width / 2.f - fCaptureButtonHeight / 2.f, fCaptureButtonY, fCaptureButtonHeight, fCaptureButtonHeight)];
    if (self.eSelectedCameraType == PHOTO_CAMERA)
        viewCaptureButton.backgroundColor = [UIColor greenColor];
    else
        viewCaptureButton.backgroundColor = [UIColor redColor];
    viewCaptureButton.layer.cornerRadius = fCaptureButtonHeight / 2.f;
    viewCaptureButton.layer.borderColor = [UIColor whiteColor].CGColor;
    viewCaptureButton.layer.borderWidth = 5.f;
    viewCaptureButton.clipsToBounds = YES;
    [_previewView addSubview:viewCaptureButton];
    
    if (self.eSelectedCameraType == PHOTO_CAMERA)
        [viewCaptureButton addGestureRecognizer:_longPressGestureRecognizerForPhoto];
    else
        [viewCaptureButton addGestureRecognizer:_TapGestureRecognizer];
    
    // flip button
    float fSettingButtonHeight = 32.f;
    _flipButton = [ExtendedHitButton extendedHitButton];
    UIImage *flipImage = [UIImage imageNamed:@"SwitchCamera"];
    [_flipButton setImage:flipImage forState:UIControlStateNormal];
    _flipButton.frame = CGRectMake(CGRectGetWidth(self.frame) - fSettingButtonHeight - 10.f, 10.f, fSettingButtonHeight, fSettingButtonHeight);
    [_flipButton addTarget:self action:@selector(_handleFlipButton:) forControlEvents:UIControlEventTouchUpInside];
    [_previewView addSubview:_flipButton];
    
    _lblStatus = [[UILabel alloc] initWithFrame:CGRectMake(0.f, fSettingButtonHeight + 14.f, CGRectGetWidth(self.frame), 20.f)];
    _lblStatus.textAlignment = NSTextAlignmentCenter;
    _lblStatus.font = [UIFont systemFontOfSize:14.f];
    _lblStatus.backgroundColor = [UIColor clearColor];
    _lblStatus.textColor = [UIColor whiteColor];
    [_previewView addSubview:_lblStatus];
    _lblStatus.text = @"Tap to record";
    if (self.eSelectedCameraType == PHOTO_CAMERA)
        _lblStatus.hidden = YES;
    
    [[PBJVision sharedInstance] setPresentationFrame:_previewView.frame];
    
    [self _resetCapture];
    [[PBJVision sharedInstance] startPreview];
}

- (void) unInitCameraView
{
    [[PBJVision sharedInstance] stopPreview];
    
    PBJVision *vision = [PBJVision sharedInstance];
    vision.delegate = nil;
    
    if (self.eSelectedCameraType == PHOTO_CAMERA)
    {
        CheckCaptureImageView* subView = (CheckCaptureImageView *)[self viewWithTag:100];
        if (subView)
        {
            [subView removeFromSuperview];
            subView = nil;
        }
    }
    else
    {
        CheckCaptureVideoView* subView = (CheckCaptureVideoView *)[self viewWithTag:100];
        if (subView)
        {
            [subView removeFromSuperview];
            subView = nil;
        }
    }
    
    _previewLayer.frame = CGRectZero;
    _previewView.frame = CGRectZero;
    [_previewLayer removeFromSuperlayer];
}

#pragma mark - UIGestureRecognizer
- (void)_handleLongPressGestureRecognizerForPhoto:(UIGestureRecognizer *)gestureRecognizer
{
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            viewCaptureButton.alpha = 0.3f;
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            viewCaptureButton.alpha = 1.f;
            [[PBJVision sharedInstance] freezePreview];
            [[PBJVision sharedInstance] capturePhoto];
            break;
        }
        default:
            break;
    }
}

- (void)_handleLongPressGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    // PHOTO: uncomment to test photo capture
    //    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
    //        [[PBJVision sharedInstance] capturePhoto];
    //        return;
    //    }
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            viewCaptureButton.alpha = 0.3f;
            
            [self _startCapture];
            
            _lblStatus.text = @"Recording...";
            
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            viewCaptureButton.alpha = 1.f;
            [self stopRecording];
            
            _lblStatus.text = @"Tap to record";
            break;
        }
        default:
            break;
    }
}

- (void)_handleSingleTap:(UIGestureRecognizer *)gestureRecognizer
{
    if (_switchForRecord == false) {
        viewCaptureButton.alpha = 0.3f;
        
        [self _startCapture];
        
        _lblStatus.text = @"Recording...";
        _switchForRecord = true;
        
    } else {
        viewCaptureButton.alpha = 1.f;
        [self stopRecording];
        
        _lblStatus.text = @"Tap to record";
        _switchForRecord = false;
    }
    
    
}

- (void) stopRecording
{
    viewCaptureButton.alpha = 1.f;
    [self _endCapture];
}

- (void)_handleFocusTapGesterRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint tapPoint = [gestureRecognizer locationInView:_previewView];
    
    // auto focus is occuring, display focus view
    CGPoint point = tapPoint;
    
    CGRect focusFrame = _focusView.frame;
#if defined(__LP64__) && __LP64__
    focusFrame.origin.x = rint(point.x - (focusFrame.size.width * 0.5));
    focusFrame.origin.y = rint(point.y - (focusFrame.size.height * 0.5));
#else
    focusFrame.origin.x = rintf(point.x - (focusFrame.size.width * 0.5f));
    focusFrame.origin.y = rintf(point.y - (focusFrame.size.height * 0.5f));
#endif
    [_focusView setFrame:focusFrame];
    
    [_previewView addSubview:_focusView];
    [_focusView startAnimation];
    
    CGPoint adjustPoint = [PBJVisionUtilities convertToPointOfInterestFromViewCoordinates:tapPoint inFrame:_previewView.frame];
    [[PBJVision sharedInstance] focusExposeAndAdjustWhiteBalanceAtAdjustedPoint:adjustPoint];
    
    
    [self performSelector:@selector(stopFocusAnimation) withObject:nil afterDelay:2.f];
}

- (void) stopFocusAnimation
{
    if (_focusView && [_focusView superview]) {
        [_focusView stopAnimation];
    }
}

#pragma mark delegate related to camera
#pragma mark - private start/stop helper methods

- (void)_startCapture
{
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
    } completion:^(BOOL finished) {
    }];
    [[PBJVision sharedInstance] startVideoCapture];
}

- (void)_pauseCapture
{
    [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
    } completion:^(BOOL finished) {
    }];
    
    [[PBJVision sharedInstance] pauseVideoCapture];
    //    _effectsViewController.view.hidden = !_onionButton.selected;
}

- (void)_resumeCapture
{
    [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
    } completion:^(BOOL finished) {
    }];
    
    [[PBJVision sharedInstance] resumeVideoCapture];
    _effectsViewController.view.hidden = YES;
}

- (void)_endCapture
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [[PBJVision sharedInstance] endVideoCapture];
    _effectsViewController.view.hidden = YES;
}

- (void)_resetCapture
{
    _longPressGestureRecognizer.enabled = YES;
    
    PBJVision *vision = [PBJVision sharedInstance];
    vision.delegate = self;
    
    if ([vision isCameraDeviceAvailable:PBJCameraDeviceBack]) {
        vision.cameraDevice = PBJCameraDeviceBack;
        //        _flipButton.hidden = NO;
    } else {
        vision.cameraDevice = PBJCameraDeviceFront;
        //        _flipButton.hidden = YES;
    }
    
    if (eSelectedCameraType == VIDEO_CAMERA)
        vision.cameraMode = PBJCameraModeVideo;
    else
        vision.cameraMode = PBJCameraModePhoto; // PHOTO: uncomment to test photo capture
    vision.cameraOrientation = PBJCameraOrientationPortrait;
    vision.focusMode = PBJFocusModeContinuousAutoFocus;
    vision.outputFormat = PBJOutputFormatSquare;
    vision.videoRenderingEnabled = YES;
    vision.additionalCompressionProperties = @{AVVideoProfileLevelKey : AVVideoProfileLevelH264Baseline30}; // AVVideoProfileLevelKey requires specific captureSessionPreset
    
    // specify a maximum duration with the following property
    // vision.maximumCaptureDuration = CMTimeMakeWithSeconds(5, 600); // ~ 5 seconds
}

#pragma mark - UIButton
- (void) _handleFlashButton:(UIButton *) button
{
    switch ([PBJVision sharedInstance].torchMode) {
        case AVCaptureTorchModeOff:
            [PBJVision sharedInstance].torchMode = AVCaptureTorchModeOn;
            break;
            
        case AVCaptureTorchModeOn:
            [PBJVision sharedInstance].torchMode = AVCaptureTorchModeAuto;
            break;
            
        case AVCaptureTorchModeAuto:
            [PBJVision sharedInstance].torchMode = AVCaptureTorchModeOff;
            break;
            
        default:
            break;
    }
    
}

- (void)updateFlashButtonByTochMode:(AVCaptureTorchMode)touchMode {
    switch (touchMode) {
        case AVCaptureTorchModeOff:
            //            [_flashButton setImage:[UIImage imageNamed:@"SwitchFlash_off"] forState:UIControlStateNormal];
            break;
            
        case AVCaptureTorchModeOn:
            //            [_flashButton setImage:[UIImage imageNamed:@"SwitchFlash_on"] forState:UIControlStateNormal];
            break;
            
        case AVCaptureTorchModeAuto:
            //            [_flashButton setImage:[UIImage imageNamed:@"SwitchFlash_auto"] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == CameraTorchModeObservationContext) {
        [self updateFlashButtonByTochMode:(AVCaptureTorchMode)[change[@"new"] intValue]];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)_handleFlipButton:(UIButton *)button
{
    PBJVision *vision = [PBJVision sharedInstance];
    vision.cameraDevice = vision.cameraDevice == PBJCameraDeviceBack ? PBJCameraDeviceFront : PBJCameraDeviceBack;
}

- (void)_handleFocusButton:(UIButton *)button
{
    /*
     _focusButton.selected = !_focusButton.selected;
     
     if (_focusButton.selected) {
     _focusTapGestureRecognizer.enabled = YES;
     _gestureView.hidden = YES;
     
     } else {
     if (_focusView && [_focusView superview]) {
     [_focusView stopAnimation];
     }
     _focusTapGestureRecognizer.enabled = NO;
     _gestureView.hidden = NO;
     }
     
     [UIView animateWithDuration:0.15f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
     _instructionLabel.alpha = 0;
     } completion:^(BOOL finished) {
     _instructionLabel.text = _focusButton.selected ? NSLocalizedString(@"Touch to focus", @"Touch to focus") :
     NSLocalizedString(@"Touch and hold to record", @"Touch and hold to record");
     [UIView animateWithDuration:0.15f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
     _instructionLabel.alpha = 1;
     } completion:^(BOOL finished1) {
     }];
     }];
     */
}

- (void)_handleFrameRateChangeButton:(UIButton *)button
{
}

- (void)_handleOnionSkinningButton:(UIButton *)button
{
    /*
     _onionButton.selected = !_onionButton.selected;
     
     if (_recording) {
     _effectsViewController.view.hidden = !_onionButton.selected;
     }
     */
}

- (void)_handleDoneButton:(UIButton *)button
{
    // resets long press
    _longPressGestureRecognizer.enabled = NO;
    _longPressGestureRecognizer.enabled = YES;
    
    //    [[GlobalPool sharedObject] showLoadingView:self.view];
    
    [self _endCapture];
}

- (void) cancelCapturedImage
{
    CheckCaptureImageView* subView = (CheckCaptureImageView *)[_previewView viewWithTag:100];
    if (subView)
    {
        [subView removeFromSuperview];
        subView = nil;
    }
}

- (void) confirmCapturedImage
{
    CheckCaptureImageView* subView = (CheckCaptureImageView *)[_previewView viewWithTag:100];
    if (subView)
    {
        [subView removeFromSuperview];
        subView = nil;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(tookPhoto:)])
        [self.delegate tookPhoto:captureImage];
}

- (void) cancelCapturedVideo
{
    CheckCaptureVideoView* subView = (CheckCaptureVideoView *)[_previewView viewWithTag:100];
    if (subView)
    {
        [subView removeFromSuperview];
        subView = nil;
    }
}

- (void) confirmCapturedVideo
{
    CheckCaptureVideoView* subView = (CheckCaptureVideoView *)[_previewView viewWithTag:100];
    if (subView)
    {
        [subView removeFromSuperview];
        subView = nil;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(tookVideo:)])
        [self.delegate tookVideo:captureVideoLink];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self _resetCapture];
}

#pragma mark - PBJVisionDelegate

// session

- (void)visionSessionWillStart:(PBJVision *)vision
{
}

- (void)visionSessionDidStart:(PBJVision *)vision
{
    if (![_previewView superview]) {
        [self addSubview:_previewView];
        [self bringSubviewToFront:_gestureView];
    }
}

- (void)visionSessionDidStop:(PBJVision *)vision
{
}

// preview

- (void)visionSessionDidStartPreview:(PBJVision *)vision
{
    NSLog(@"Camera preview did start");
    
    if ([[PBJVision sharedInstance] cameraHasTorch]) {
        [[PBJVision sharedInstance] addObserver:self forKeyPath:@"torchMode" options:NSKeyValueObservingOptionNew context:CameraTorchModeObservationContext];
    }
    else {
        //        _flashButton.hidden = YES;
    }
    
}

- (void)visionSessionDidStopPreview:(PBJVision *)vision
{
    NSLog(@"Camera preview did stop");
    [_previewView removeFromSuperview];
}

// device

- (void)visionCameraDeviceWillChange:(PBJVision *)vision
{
    NSLog(@"Camera device will change");
}

- (void)visionCameraDeviceDidChange:(PBJVision *)vision
{
    NSLog(@"Camera device did change");
}

// mode

- (void)visionCameraModeWillChange:(PBJVision *)vision
{
    NSLog(@"Camera mode will change");
}

- (void)visionCameraModeDidChange:(PBJVision *)vision
{
    NSLog(@"Camera mode did change");
}

// format

- (void)visionOutputFormatWillChange:(PBJVision *)vision
{
    NSLog(@"Output format will change");
}

- (void)visionOutputFormatDidChange:(PBJVision *)vision
{
    NSLog(@"Output format did change");
}

- (void)vision:(PBJVision *)vision didChangeCleanAperture:(CGRect)cleanAperture
{
}

// focus / exposure

- (void)visionWillStartFocus:(PBJVision *)vision
{
}

- (void)visionDidStopFocus:(PBJVision *)vision
{
    if (_focusView && [_focusView superview]) {
        [_focusView stopAnimation];
    }
}

- (void)visionWillChangeExposure:(PBJVision *)vision
{
}

- (void)visionDidChangeExposure:(PBJVision *)vision
{
    if (_focusView && [_focusView superview]) {
        [_focusView stopAnimation];
    }
}

// flash

- (void)visionDidChangeFlashMode:(PBJVision *)vision
{
    NSLog(@"Flash mode did change");
}

// photo

- (void)visionWillCapturePhoto:(PBJVision *)vision
{
}

- (void)visionDidCapturePhoto:(PBJVision *)vision
{
}

- (void)vision:(PBJVision *)vision capturedPhoto:(NSDictionary *)photoDict error:(NSError *)error
{
    if (eSelectedCameraType != PHOTO_CAMERA)
        return;
    
    [vision unfreezePreview];
    
    if (error) {
        // handle error properly
        
        //        [[GlobalPool sharedObject] hideLoadingView:self.view];
        
        //        [g_Delegate AlertFailure:@"Encounted an error in photo capture, Please try again!"];
        
        return;
    }
    
    _currentPhoto = photoDict;
    
    // save to library
    captureImage = [_currentPhoto[PBJVisionPhotoImageKey] fixOrientation];//[[UIImage imageWithData:photoData] fixOrientation];
    captureImage = [self scaleAndCropImage:captureImage toSize:CGSizeMake(640, 640)];
    if (self.delegate && [self.delegate respondsToSelector:@selector(tookPhoto:)])
        [self.delegate tookPhoto:captureImage];

    CheckCaptureImageView* subView = [[[NSBundle mainBundle] loadNibNamed:@"CheckCaptureImageView" owner:self options:nil] objectAtIndex:0];
    subView.frame = self.bounds;
    subView.tag = 100;
    subView.delegate = self;
    subView.m_imgView.image = captureImage;
    [_previewView addSubview:subView];
    
    return;
}

-(UIImage*) scaleAndCropImage:(UIImage *) imgSource toSize:(CGSize)newSize
{
    float ratio = imgSource.size.width / imgSource.size.height;
    
    UIGraphicsBeginImageContext(newSize);
    
    if (ratio > 1) {
        CGFloat newWidth = ratio * newSize.width;
        CGFloat newHeight = newSize.height;
        CGFloat leftMargin = (newWidth - newHeight) / 2;
        [imgSource drawInRect:CGRectMake(-leftMargin, 0, newWidth, newHeight)];
    }
    else {
        CGFloat newWidth = newSize.width;
        CGFloat newHeight = newSize.height / ratio;
        CGFloat topMargin = (newHeight - newWidth) / 2;
        [imgSource drawInRect:CGRectMake(0, -topMargin, newSize.width, newSize.height/ratio)];
    }
    
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

// video capture

- (void)visionDidStartVideoCapture:(PBJVision *)vision
{
    _recording = YES;
}

- (void)visionDidPauseVideoCapture:(PBJVision *)vision
{
}

- (void)visionDidResumeVideoCapture:(PBJVision *)vision
{
}

- (void)vision:(PBJVision *)vision capturedVideo:(NSDictionary *)videoDict error:(NSError *)error
{
    if (eSelectedCameraType != VIDEO_CAMERA)
        return;
    
    _recording = NO;
    
    if (error && [error.domain isEqual:PBJVisionErrorDomain] && error.code == PBJVisionErrorCancelled) {
        NSLog(@"recording session cancelled");
        
        return;
    } else if (error) {
        NSLog(@"encounted an error in video capture (%@)", error);
        
        return;
    }
    
    _currentVideo = videoDict;
    
    NSString *videoPath = [_currentVideo  objectForKey:PBJVisionVideoPathKey];
    
    captureVideoLink = [NSURL fileURLWithPath:videoPath];
    if (self.delegate && [self.delegate respondsToSelector:@selector(tookVideo:)])
        [self.delegate tookVideo:captureVideoLink];
    
    CheckCaptureVideoView* subView = [[[NSBundle mainBundle] loadNibNamed:@"CheckCaptureVideoView" owner:self options:nil] objectAtIndex:0];
    subView.frame = self.bounds;
    subView.tag = 100;
    subView.delegate = self;
    subView.m_strVideoPath = videoPath;
    [_previewView addSubview:subView];
    
    subView.movie = [[MPMoviePlayerController alloc] init];
    subView.movie.view.frame = CGRectMake(0, 0, CGRectGetHeight(self.bounds), CGRectGetHeight(self.bounds));
    [subView.m_viewVideoPlayerCanvas addSubview:subView.movie.view];
    
    subView.movie.view.translatesAutoresizingMaskIntoConstraints = YES;
    
    [subView loadVideo];
    
    /*
     // added by Lee (Saved captured video to album)
     //    NSString *videoPath = [_currentVideo  objectForKey:PBJVisionVideoPathKey];
     [_assetLibrary writeVideoAtPathToSavedPhotosAlbum:[NSURL URLWithString:videoPath] completionBlock:^(NSURL *assetURL, NSError *error1) {
     UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Video Saved!" message: @"Saved to the camera roll."
     delegate:self
     cancelButtonTitle:nil
     otherButtonTitles:@"OK", nil];
     [alert show];
     }];
     */
}

// progress

- (void)vision:(PBJVision *)vision didCaptureVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    //    NSLog(@"captured audio (%f) seconds", vision.capturedAudioSeconds);
}

- (void)vision:(PBJVision *)vision didCaptureAudioSample:(CMSampleBufferRef)sampleBuffer
{
    //    NSLog(@"captured video (%f) seconds", vision.capturedVideoSeconds);
    /*
     float fCurrentWidth = viewCurrentTimeline.frame.size.width;
     float fStep = CGRectGetWidth(self.view.frame) / MAX_VIDEO_RECORD_TIME * (vision.capturedVideoSeconds - fPrevTimeline);
     NSLog(@"prev = %f, step width = %f, total = %f", fPrevTimeline, fStep, fCurrentWidth);
     viewCurrentTimeline.frame = CGRectMake(viewCurrentTimeline.frame.origin.x, 0, fCurrentWidth + fStep, VIDEO_TIMELINE_HEIGHT);
     fPrevTimeline = vision.capturedVideoSeconds;
     
     if (viewCurrentTimeline.frame.origin.x + viewCurrentTimeline.frame.size.width >= self.view.frame.size.width)
     {
     bAlreadyLimited = true;
     [self stopRecording];
     }
     */
}

@end
