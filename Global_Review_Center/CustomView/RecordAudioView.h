//
//  RecordAudioView.h
//  Global_Review_Center
//
//  Created by Admin on 1/28/16.
//  Copyright © 2016 Oleg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@protocol RecordAudioViewDelegate;

@interface RecordAudioView : UIView<AVAudioRecorderDelegate, AVAudioPlayerDelegate>
{
    bool bRecorded;
    BOOL _switch;
    
    UIImage* imgPlayAudio;
    UIImage* imgStopAudio;
    
    bool bPlayingAudio;
    
    UITapGestureRecognizer *_TapGestureRecognizer;
    
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
}

@property (nonatomic, weak) id<RecordAudioViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *m_lblGuide;

@property (nonatomic, strong) NSTimer *progressTimer;
@property (nonatomic) CGFloat progress;

@property (weak, nonatomic) IBOutlet UIView *m_viewRecordBtnCanvas;

@property (weak, nonatomic) IBOutlet UIButton *m_btnRecord;
- (IBAction)actionStartRecording:(id)sender;
- (IBAction)actionStopRecording:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *m_viewProgressCanvas;
@property (weak, nonatomic) IBOutlet UIView *m_viewProgress;

@property (weak, nonatomic) IBOutlet UIButton *m_btnPlayStopAudio;
- (IBAction)actionPlayStopAudio:(id)sender;

@end

@protocol RecordAudioViewDelegate <NSObject>

- (void) recordedAudio:(NSURL *) audioLink;

@end