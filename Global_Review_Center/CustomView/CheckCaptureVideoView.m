//
//  CheckCaptureVideoView.m
//  Global_Review_Center
//
//  Created by Admin on 1/28/16.
//  Copyright © 2016 Oleg. All rights reserved.
//

#import "CheckCaptureVideoView.h"
#import "FAKFontAwesome.h"

@implementation CheckCaptureVideoView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (void) awakeFromNib
{
    float fIconSize = 32.f;
    
    FAKFontAwesome *cancelIcon = [FAKFontAwesome timesCircleIconWithSize:fIconSize];
    [cancelIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *imgCancel = [cancelIcon imageWithSize:CGSizeMake(fIconSize, fIconSize)];
    [self.m_btnCancel setImage:imgCancel forState:UIControlStateNormal];
    
    FAKFontAwesome *playIcon = [FAKFontAwesome playIconWithSize:fIconSize];
    [playIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *imgPlay = [playIcon imageWithSize:CGSizeMake(fIconSize, fIconSize)];
    [self.m_btnPlay setImage:imgPlay forState:UIControlStateNormal];
    
    FAKFontAwesome *stopIcon = [FAKFontAwesome stopIconWithSize:fIconSize];
    [stopIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *imgStop = [stopIcon imageWithSize:CGSizeMake(fIconSize, fIconSize)];
    [self.m_btnStop setImage:imgStop forState:UIControlStateNormal];
    
}

//when movie state is changed
- (void)movieStateChanged:(NSNotification *)note
{
    if (note.object == self.movie && [self.movie playbackState] == MPMoviePlaybackStatePlaying)
    {
    }
    
    if (note.object == self.movie && [self.movie playbackState] == MPMoviePlaybackStateStopped)
    {
        [self.movie stop];
    }
}

//when movie is finished
- (void) movieFinished:(NSNotification *) note
{
    if (note.object == self.movie) {
        NSInteger reason = [[note.userInfo objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] integerValue];
        if (reason == MPMovieFinishReasonPlaybackEnded)
        {
            NSLog(@"finished playing");
        }
    }
    
}

- (void) loadVideo
{
    if ([self.movie playbackState] == MPMoviePlaybackStatePlaying)
        [self.movie stop];
    
    [self.movie setContentURL:nil];
    
    NSURL *url = [NSURL fileURLWithPath:self.m_strVideoPath];
    
    if (!url)
    {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Not available to play this video!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        
        return;
    }
    
    self.movie.controlStyle = MPMovieControlStyleNone;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieStateChanged:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:self.movie];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieFinished:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:self.movie];
    
    self.movie.movieSourceType = MPMovieSourceTypeFile;
    self.movie.scalingMode = MPMovieScalingModeAspectFit;
    [self.movie setContentURL:url];
    [self.movie setShouldAutoplay:NO];
    [self.movie prepareToPlay];
}

- (IBAction)actionPlayVideo:(id)sender {
    [self.movie play];
}

- (IBAction)actionStopVideo:(id)sender {
    [self.movie stop];
}

- (IBAction)actionCancel:(id)sender {
    if (self.delegate || [self.delegate respondsToSelector:@selector(cancelCapturedVideo)])
        [self.delegate cancelCapturedVideo];
}

@end
