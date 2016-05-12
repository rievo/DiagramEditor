//
//  DrawingAlert.m
//  DiagramEditor
//
//  Created by Diego on 9/5/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "DrawingAlert.h"

@implementation DrawingAlert


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.



- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
- (void)drawRect:(CGRect)rect {
    
    UIBezierPath * circle = [UIBezierPath bezierPathWithOvalInRect:self.frame];
    [[UIColor redColor]setFill];
    [circle fill];
}


@end
