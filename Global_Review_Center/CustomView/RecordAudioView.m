//
//  RecordAudioView.m
//  Global_Review_Center
//
//  Created by Admin on 1/28/16.
//  Copyright © 2016 Oleg. All rights reserved.
//

#import "RecordAudioView.h"
#import "FAKFontAwesome.h"

#define MAX_VIDEO_RECORD_TIME       60

@implementation RecordAudioView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (void)awakeFromNib
{
    bPlayingAudio = false;
    bRecorded = false;
    _switch = false;
    
    self.m_lblGuide.text = @"Tap to record";
    
    self.m_btnPlayStopAudio.enabled = NO;
    
    float fIconSize = 32.f;
    
    
    
    _TapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleSingleTap:)];
    [self.m_viewRecordBtnCanvas addGestureRecognizer:_TapGestureRecognizer];
    

    FAKFontAwesome *playIcon = [FAKFontAwesome playIconWithSize:fIconSize];
    [playIcon addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor]];
    imgPlayAudio = [playIcon imageWithSize:CGSizeMake(fIconSize, fIconSize)];
    
    FAKFontAwesome *stopIcon = [FAKFontAwesome stopIconWithSize:fIconSize];
    [stopIcon addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor]];
    imgStopAudio = [stopIcon imageWithSize:CGSizeMake(fIconSize, fIconSize)];
    
    [self.m_btnPlayStopAudio setImage:imgPlayAudio forState:UIControlStateNormal];
    self.m_btnRecord.backgroundColor = [UIColor redColor];
    
    [self makeCornerRadiusControl:self.m_viewRecordBtnCanvas radius:CGRectGetHeight(self.m_viewRecordBtnCanvas.frame) / 2.f backgroundcolor:[UIColor whiteColor] borderColor:[UIColor redColor] borderWidth:2.f];
    [self makeCornerRadiusControl:self.m_btnRecord radius:CGRectGetHeight(self.m_btnRecord.frame) / 2.f backgroundcolor:[UIColor redColor] borderColor:[UIColor redColor] borderWidth:0.f];
    
    [self makeCornerRadiusControl:self.m_viewProgressCanvas radius:CGRectGetHeight(self.m_viewProgressCanvas.frame) / 2.f backgroundcolor:[UIColor whiteColor] borderColor:[UIColor darkGrayColor] borderWidth:2.f];
    
    self.m_viewProgress.backgroundColor = [UIColor darkGrayColor];
    self.m_viewProgress.frame = CGRectZero;
    
    self.m_viewRecordBtnCanvas.backgroundColor = [UIColor redColor];
    //    self.m_viewRecordBtnCanvas.cornerRadius = fCaptureButtonHeight / 2.f;
    self.m_viewRecordBtnCanvas.layer.borderColor = [UIColor whiteColor].CGColor;
    self.m_viewRecordBtnCanvas.layer.borderWidth = 5.f;
    self.m_viewRecordBtnCanvas.clipsToBounds = YES;
    
    [self prepareRecording];
}

- (void) makeCornerRadiusControl:(UIView *) targetView radius:(float) fRadius backgroundcolor:(UIColor *) bgColor borderColor:(UIColor *) borderColor borderWidth:(float) fBorderWidth
{
    targetView.backgroundColor = bgColor;
    targetView.layer.cornerRadius = fRadius;
    targetView.layer.borderColor = borderColor.CGColor;
    targetView.layer.borderWidth = fBorderWidth;
    targetView.clipsToBounds = YES;
    
}

- (void) prepareRecording
{
    // Set the audio file
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"record.wav",
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [recordSetting setObject:[NSNumber numberWithFloat:44100.0] forKey: AVSampleRateKey];
    [recordSetting setObject:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
    [recordSetting setObject:[NSNumber numberWithInt:12800] forKey:AVEncoderBitRateKey];
    [recordSetting setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [recordSetting setObject:[NSNumber numberWithInt: AVAudioQualityHigh] forKey: AVEncoderAudioQualityKey];
    
    // Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
}

- (NSString *)fullPathAtCache:(NSString *)fileName{
    NSError *error;
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (YES != [fm fileExistsAtPath:path]) {
        if (YES != [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"create dir path=%@, error=%@", path, error);
        }
    }
    return [path stringByAppendingPathComponent:fileName];
}

- (void) refreshRecording
{
    self.progress = 0;
    
    bRecorded = false;
    
    unlink([[self fullPathAtCache:@"record.wav"] UTF8String]);
    
    self.m_viewProgress.frame = CGRectZero;
}

- (void)recording {
    self.m_lblGuide.text = @"Recording your voice now...";
    
    NSLog(@"Started recording");
    
    [self refreshRecording];
    
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    
    // Start recording
    [recorder record];
}

- (void)endRecording {
    self.m_lblGuide.text = @"Tap to record";
    
    NSLog(@"Paused recording.");
    [self.progressTimer invalidate];
    
    self.m_btnPlayStopAudio.enabled = YES;
    [self.m_btnPlayStopAudio setImage:imgPlayAudio forState:UIControlStateNormal];
    
    [recorder stop];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordedAudio:)])
        [self.delegate recordedAudio:recorder.url];
}

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
}

- (void)updateProgress {
    self.progress += 0.05/MAX_VIDEO_RECORD_TIME;
    self.m_viewProgress.frame = CGRectMake(0, 0, CGRectGetWidth(self.m_viewProgressCanvas.frame) / MAX_VIDEO_RECORD_TIME * self.progress * 100.f, CGRectGetHeight(self.frame));
    
    if (self.progress >= 1)
    {
        [self.progressTimer invalidate];
        
        [self actionStopRecording:self.m_btnRecord];
    }
}

//- (IBAction)actionStartRecording:(id)sender {
//    self.m_btnRecord.alpha = 0.3f;
//    
//    self.m_viewProgress.frame = CGRectZero;
//    
//    bPlayingAudio = false;
//    
//    self.m_btnPlayStopAudio.enabled = NO;
//    [self.m_btnPlayStopAudio setImage:imgPlayAudio forState:UIControlStateNormal];
//    
//    [self recording];
//}
//
//- (IBAction)actionStopRecording:(id)sender {
//    self.m_btnRecord.alpha = 1.f;
//    
//    bPlayingAudio = false;
//    
//    [self endRecording];
//}

- (IBAction)actionPlayStopAudio:(id)sender {
    bPlayingAudio = !bPlayingAudio;
    
    if (bPlayingAudio)
    {
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
        [player setDelegate:self];
        [player play];
        
        [self.m_btnPlayStopAudio setImage:imgStopAudio forState:UIControlStateNormal];
    }
    else
    {
        [player stop];
        player.delegate = nil;
        player = nil;
        
        [self.m_btnPlayStopAudio setImage:imgPlayAudio forState:UIControlStateNormal];
    }
}

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [self.m_btnPlayStopAudio setImage:imgPlayAudio forState:UIControlStateNormal];
}



- (void)_handleSingleTap:(UIGestureRecognizer *)gestureRecognizer
{
    if (_switch == false) {
        self.m_viewRecordBtnCanvas.alpha = 0.3f;
        self.m_btnRecord.alpha = 0.3f;
        
        self.m_viewProgress.frame = CGRectZero;
        
        bPlayingAudio = false;
        
        self.m_btnPlayStopAudio.enabled = NO;
        [self.m_btnPlayStopAudio setImage:imgPlayAudio forState:UIControlStateNormal];
        
        [self recording];
        _switch = true;
        
    } else {
        self.m_viewRecordBtnCanvas.alpha = 1.f;
        self.m_btnRecord.alpha = 1.f;
        
        bPlayingAudio = false;
        
        [self endRecording];
        _switch = false;
    }
    
    
}



@end
