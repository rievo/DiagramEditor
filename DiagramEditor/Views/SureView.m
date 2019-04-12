//
//  SureView.m
//  DiagramEditor
//
//  Created by Diego on 26/1/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "SureView.h"

@implementation SureView

@synthesize delegate, background;

- (void)awakeFromNib{
    [super awakeFromNib];
    UITapGestureRecognizer * tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                             action:@selector(handleTap:)];
    [background addGestureRecognizer:tapgr];
    [tapgr setDelegate:self];
}

- (IBAction)sayNo:(UIButton *)sender {
    [self removeFromSuperview];
    [delegate closeSureViewWithResult:NO];
}

- (IBAction)sayYes:(id)sender {
    [self removeFromSuperview];
    [delegate closeSureViewWithResult:YES];
}

-(void)handleTap: (UITapGestureRecognizer *)recog{
    [self removeFromSuperview];
    [delegate closeSureViewWithResult:NO];
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
