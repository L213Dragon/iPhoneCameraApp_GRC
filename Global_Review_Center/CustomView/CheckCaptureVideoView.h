//
//  CheckCaptureVideoView.h
//  Global_Review_Center
//
//  Created by Admin on 1/28/16.
//  Copyright © 2016 Oleg. All rights reserved.
//

#import <UIKit/UIKit.h>
@import AVFoundation;
@import MediaPlayer;

@protocol CheckCaptureVideoViewDelegate;

@interface CheckCaptureVideoView : UIView

@property (nonatomic, weak) id<CheckCaptureVideoViewDelegate> delegate;

@property (nonatomic, strong) NSString* m_strVideoPath;

@property (nonatomic, strong) MPMoviePlayerController *movie;

@property (weak, nonatomic) IBOutlet UIView *m_viewVideoPlayerCanvas;

@property (weak, nonatomic) IBOutlet UIButton *m_btnPlay;
- (IBAction)actionPlayVideo:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *m_btnStop;
- (IBAction)actionStopVideo:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *m_btnCancel;
- (IBAction)actionCancel:(id)sender;


- (void) loadVideo;

@end

@protocol CheckCaptureVideoViewDelegate <NSObject>

- (void) cancelCapturedVideo;
- (void) confirmCapturedVideo;

@end