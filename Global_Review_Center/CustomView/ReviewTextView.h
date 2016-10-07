//
//  ReviewTextView.h
//  Global_Review_Center
//
//  Created by Admin on 1/28/16.
//  Copyright © 2016 Oleg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReviewTextView : UIView<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *m_txtView;

- (void) hideTextViewKeyboard;

@end

