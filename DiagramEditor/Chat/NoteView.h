//
//  NoteView.h
//  DiagramEditor
//
//  Created by Diego on 23/5/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>


@class AppDelegate;

@interface NoteView : UIView<UIGestureRecognizerDelegate>{
    
    __weak IBOutlet UIView *container;
    AppDelegate * dele;
    
    UIColor * color;
}
@property (weak, nonatomic) IBOutlet UIImageView *preview;
@property (weak, nonatomic) IBOutlet UIView *background;
@property (weak, nonatomic) IBOutlet UILabel *whoLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;

- (IBAction)deleteThisNote:(id)sender;
- (IBAction)closeThisView:(id)sender;

@end
