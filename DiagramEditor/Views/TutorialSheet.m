//
//  TutorialSheet.m
//  DiagramEditor
//
//  Created by Diego on 2/6/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "TutorialSheet.h"

#import "AppDelegate.h"

@implementation TutorialSheet


- (void)drawRect:(CGRect)rect {
    UIBezierPath * back = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:5.0];
    [dele.blue3 setStroke];
    [dele.blue2 setFill];
    
    [back setLineWidth:4.0];
    [back fill];
    [back stroke];
}


-(void)prepare{
    dele = [[UIApplication sharedApplication]delegate];
}


@end
