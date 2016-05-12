//
//  PasteView.h
//  DiagramEditor
//
//  Created by Diego on 21/1/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol PasteViewDelegate;

@interface PasteView : UIView<UIGestureRecognizerDelegate, UITextViewDelegate>{
    id delegate;
    __weak IBOutlet UIView *blueView;
}

@property (weak, nonatomic) IBOutlet UITextView *textview;

@property UIView * backView;
@property (nonatomic, retain) id delegate;

@property (weak, nonatomic) IBOutlet UIView *background;

- (IBAction)ok:(id)sender;

@end



@protocol PasteViewDelegate

@required
-(void)saveTextFromPasteView:(PasteView *) pasteView;

@end
