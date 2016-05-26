//
//  NoteView.h
//  DiagramEditor
//
//  Created by Diego on 23/5/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>


@class AppDelegate;
@class Alert;

@interface NoteView : UIView<UIGestureRecognizerDelegate, UIScrollViewDelegate, UITextViewDelegate>{
    
    __weak IBOutlet UIView *container;
    AppDelegate * dele;
    
    UIColor * color;
    __weak IBOutlet UIScrollView *scrollView;
    
    UITextView * tv;
    
    CGRect oldFrame;
}
//property (weak, nonatomic) IBOutlet UIImageView *preview;
@property (weak, nonatomic) IBOutlet UIView *background;
@property (weak, nonatomic) IBOutlet UILabel *whoLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property NSString * content;
@property UIImage * preview;

@property Alert * associatedNote;

- (IBAction)deleteThisNote:(id)sender;
- (IBAction)closeThisView:(id)sender;

-(void)prepare;

@end
