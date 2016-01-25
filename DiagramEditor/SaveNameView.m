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
@end
