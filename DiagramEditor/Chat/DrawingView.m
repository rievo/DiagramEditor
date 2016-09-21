//
//  DrawingView.m
//  DiagramEditor
//
//  Created by Diego on 25/5/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "DrawingView.h"
#import "EditorViewController.h"


@implementation DrawingView

@synthesize delegate, owner;

- (void)drawRect:(CGRect)rect
{
    //Draw background
    UIBezierPath * back = [UIBezierPath bezierPathWithRect:canvas.frame];
    UIColor * col = [UIColor colorWithRed:0.5 green:0.7 blue:0.1 alpha:0.5];
    [col setFill];
    [back fill];
    
    
    [[UIColor blackColor] setStroke];
    [path stroke];
}




- (IBAction)cancelDrawing:(id)sender {
    [self removeFromSuperview];
    [delegate drawingViewDidCancel];
    
}

- (IBAction)saveDrawing:(id)sender {
    [self removeFromSuperview];
    CGPoint oldOff = owner.scrollView.contentOffset;
    oldOff.x = (oldOff.x - canvas.frame.origin.x);
    oldOff.y = (oldOff.y -canvas.frame.origin.y) ;

    
    
    CGAffineTransform translation = CGAffineTransformMakeTranslation(oldOff.x,
                                                                     oldOff.y);
    CGPathRef movedPath = CGPathCreateCopyByTransformingPath(path.CGPath,
                                                             &translation);
    UIBezierPath * mo = [UIBezierPath bezierPathWithCGPath:movedPath];
    
    [mo setLineWidth:2.0];
    [mo applyTransform:CGAffineTransformMakeScale(1/owner.scrollView.zoomScale, 1/owner.scrollView.zoomScale)];
    
    
    [delegate drawingViewDidCloseWithPath:mo];
}

-(void)prepare{
    path = [[UIBezierPath alloc] init];
    
    dele =(AppDelegate *) [[UIApplication sharedApplication]delegate];
    
    canvas = [[UIView alloc] initWithFrame:owner.scrollView.frame];
    //canvas.backgroundColor = [UIColor colorWithRed:0.5 green:0.7 blue:0.1 alpha:0.5];
    canvas.backgroundColor = [UIColor clearColor];
    
    [self addSubview:canvas];
    
    [self sendSubviewToBack:canvas];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    
    if(CGRectContainsPoint(canvas.frame, p)){
        [path moveToPoint:p];
    }
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    if(CGRectContainsPoint(canvas.frame, p)){
        [path addLineToPoint:p];
        [self setNeedsDisplay];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesMoved:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

@end
