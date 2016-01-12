//
//  PItemEditor.m
//  DiagramEditor
//
//  Created by Diego Vaquero Melchor on 12/1/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "PItemEditor.h"
#import "AppDelegate.h"

#define lowLineWidth 4.0f
#define highLineWidth 8.0f
@implementation PItemEditor

@synthesize incrementalImage;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setMultipleTouchEnabled:NO];
        path = [UIBezierPath bezierPath];
        [path setLineWidth:highLineWidth];
    }
    return self;
}


-(void)prepareEditor{
    
    dele = [UIApplication sharedApplication].delegate;
    [self setMultipleTouchEnabled:NO];
    path = [UIBezierPath bezierPath];
    [path setLineWidth:highLineWidth];
}





- (void)drawRect:(CGRect)rect {
    [incrementalImage drawInRect:rect];
    [path stroke];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    ctr = 0;
    UITouch *touch = [touches anyObject];
    pts[0] = [touch locationInView:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    ctr++;
    pts[ctr] = p;
    if (ctr == 4)
    {
        pts[3] = CGPointMake((pts[2].x + pts[4].x)/2.0, (pts[2].y + pts[4].y)/2.0); // move the endpoint to the middle of the line joining the second control point of the first Bezier segment and the first control point of the second Bezier segment
        
        [path moveToPoint:pts[0]];
        [path addCurveToPoint:pts[3] controlPoint1:pts[1] controlPoint2:pts[2]]; // add a cubic Bezier from pt[0] to pt[3], with control points pt[1] and pt[2]
        
        [self setNeedsDisplay];
        // replace points and get ready to handle the next segment
        pts[0] = pts[3];
        pts[1] = pts[4];
        ctr = 1;
        

    }
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self drawBitmap];
    [self setNeedsDisplay];
    [path removeAllPoints];
    ctr = 0;
}


- (void)drawBitmap
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0.0);
    
    if (!incrementalImage) // first time; paint background white
    {
        
        UIBezierPath *rectpath = [UIBezierPath bezierPathWithRect:self.bounds];
        [dele.blue4 setFill];
        [rectpath fill];
        [[UIColor blackColor]setStroke];
        [rectpath stroke];
        //[path setLineWidth:lowLineWidth];
    }
    [incrementalImage drawAtPoint:CGPointZero];
    [[UIColor blackColor] setStroke];
    [path stroke];
    incrementalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

@end
