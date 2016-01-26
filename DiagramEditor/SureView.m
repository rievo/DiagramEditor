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



- (IBAction)sayNo:(UIButton *)sender {
    [background removeFromSuperview];
    [delegate closeSureViewWithResult:NO];
}

- (IBAction)sayYes:(id)sender {
    [background removeFromSuperview];
    [delegate closeSureViewWithResult:YES];
}
@end
