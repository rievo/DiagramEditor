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
@end
