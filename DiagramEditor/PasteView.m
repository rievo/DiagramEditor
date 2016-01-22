//
//  PasteView.m
//  DiagramEditor
//
//  Created by Diego on 21/1/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "PasteView.h"

@implementation PasteView

@synthesize textview, backView, delegate;

- (IBAction)cancel:(id)sender {
    
    //[self removeFromSuperview]
    [backView removeFromSuperview];
}
- (IBAction)ok:(id)sender {
    //return textview.text;
    [backView removeFromSuperview];
    NSLog(@"Voy a llamar al método delegado");
    [delegate saveTextFromPasteView:self];
}

@end
