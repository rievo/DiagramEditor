//
//  SavaNameView.m
//  DiagramEditor
//
//  Created by Diego on 25/1/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "SaveNameView.h"

@implementation SaveNameView


@synthesize delegate, textField;

-(void)awakeFromNib{
    UITapGestureRecognizer * tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [background addGestureRecognizer:tapgr];
    [tapgr setDelegate:self];
    
    
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(keyboardOnScreen:)
                   name:UIKeyboardWillShowNotification
                 object:nil];
    
    
    
    [center addObserver:self
               selector:@selector(keyboardOutOfScreen:)
                   name:UIKeyboardWillHideNotification
                 object:nil];
}

- (IBAction)confirmSaving:(id)sender {
    
    if(textField.text.length > 0){
        NSString * fixedName = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        [delegate saveName: [fixedName lowercaseString]];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Name cannot be empty"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)cancelSaving:(id)sender {
    [delegate cancelSaving];
}


-(void)handleTap: (UITapGestureRecognizer *)recog{
    [self removeFromSuperview];
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    
    [self endEditing:YES];
    if (touch.view != background) { // accept only touchs on superview, not accept touchs on subviews
        return NO;
    }
    
    return YES;
}

-(void)keyboardOutOfScreen:(NSNotification *)not{
    [self endEditing:YES];
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         //[bottomBar setFrame:oldFrame];
                         [container setFrame:oldFrame];
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    
}


-(void)keyboardOnScreen:(NSNotification *)not{
    
    oldFrame = container.frame;
    
    NSDictionary * dicNot = not.userInfo;
    
    NSValue *val = dicNot[UIKeyboardFrameEndUserInfoKey];
    
    CGRect rawFrame = [val CGRectValue];
    
    CGRect keyboardFrame = [self convertRect:rawFrame fromView:nil];
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         /*[bottomBar setFrame:CGRectMake(bottomBar.frame.origin.x,
                                                        keyboardFrame.origin.y - bottomBar.frame.size.height*2,
                                                        bottomBar.frame.size.width,
                                                        bottomBar.frame.size.height)];*/
                         [container setFrame:CGRectMake(container.frame.origin.x
                          ,keyboardFrame.origin.y - container.frame.size.height
                          ,container.frame.size.width
                          ,container.frame.size.height
                          )];
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    
}

@end
