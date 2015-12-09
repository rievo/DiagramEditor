//
//  Canvas.m
//  DiagramEditor
//
//  Created by Diego Vaquero Melchor on 9/12/15.
//  Copyright © 2015 Diego Vaquero Melchor. All rights reserved.
//

#import "Canvas.h"

@implementation Canvas


@synthesize xArrowEnd, yArrowEnd, xArrowStart, yArrowStart;


- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}




-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}


-(void)prepareCanvas{
    
    xArrowStart = -1.0;
    yArrowStart = -1.0;
    
    dele = [[UIApplication sharedApplication]delegate];
    
    [self setUserInteractionEnabled:YES];
}


-(CGPoint) getBestAnchorForComponent: (Component *)c
                             toPoint: (CGPoint)p{
    CGPoint temp;
    
    CGPoint origin = c.frame.origin;
    
    int yflag = -1, xflag = -1;
    
    if(p.y <= origin.y)
        yflag = 1;
    else if(p.y  >origin.y && p.y <= origin.y + c.frame.size.height)
        yflag = 2;
    else
        yflag = 3;
    
    if(p.x <= origin.x)
        xflag = 1;
    else if(p.x > origin.x && p.x <= origin.x + c.frame.size.width)
        xflag = 2;
    else
        xflag = 3;
    
    if(yflag == 1){
        //TopAnchorPoint
        temp = [c getTopAnchorPoint];
    }else if(yflag == 2){
        if(xflag == 1){
            //LeftAnchor
            temp = [c getLeftAnchorPoint];
        }else if(xflag == 3){
            //RightAnchor
            temp = [c getRightAnchorPoint];
        }else{
            //TopAnchor
            temp = [c getTopAnchorPoint];
        }
    }else if(yflag == 3){
        //botAnchor
        temp = [c getBotAnchorPoint];
    }
    
    return temp;
}


- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if(xArrowStart> 0 && yArrowStart> 0){
        //Dibujo la línea
        
        CGContextSetLineWidth(context, 2.0);
        CGContextSetStrokeColorWithColor(context, [UIColor
                                                   blueColor].CGColor);
        CGContextMoveToPoint(context, xArrowStart, yArrowStart);
        CGContextAddLineToPoint(context, xArrowEnd , yArrowEnd);
        CGContextStrokePath(context);
    }
    /*
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if(xArrowStart> 0 && yArrowStart> 0){
        //Dibujo la línea
        
        CGContextSetLineWidth(context, 2.0);
        CGContextSetStrokeColorWithColor(context, [UIColor
                                                   blueColor].CGColor);
        CGContextMoveToPoint(context, xArrowStart, yArrowStart);
        CGContextAddLineToPoint(context, xArrowEnd , yArrowEnd);
        CGContextStrokePath(context);
    }
    
    //Draw every connections between components
    
    Component * outComp = nil;
    
    for(int i = 0; i< [dele.componentsArray count]; i++){
        outComp = [dele.componentsArray objectAtIndex:i];
        
        //Recorremos el array de conexiones y pintamos
        
        for(int k = 0; k< [outComp.connections count]; k++){
            //Component * inside = [outComp.connections objectAtIndex:k];
            Connection * inside = [outComp.connections objectAtIndex:k];
            
            Component * insideComp = inside.toComponent;
            
            
            if(insideComp == outComp){
                
                UIBezierPath * path = [[UIBezierPath alloc]init];
                CGPoint tempPoint;
                
                [[UIColor blackColor]setStroke];
                
                [path setLineWidth:2.0];
                tempPoint = CGPointMake([insideComp getLeftAnchorPoint].x, [insideComp getLeftAnchorPoint].y -10);
                [path moveToPoint: tempPoint];
                tempPoint = CGPointMake([insideComp getLeftAnchorPoint]. x -30, [insideComp getLeftAnchorPoint].y -10);
                [path addLineToPoint:tempPoint];
                tempPoint = CGPointMake([insideComp getLeftAnchorPoint].x -30, [insideComp getTopAnchorPoint].y -50);
                [path addLineToPoint:tempPoint];
                tempPoint = CGPointMake([insideComp getTopAnchorPoint].x -10, [insideComp getTopAnchorPoint].y - 50);
                [path addLineToPoint:tempPoint];
                tempPoint = CGPointMake([insideComp getTopAnchorPoint].x -10, [insideComp getTopAnchorPoint].y);
                [path addLineToPoint:tempPoint];
                
                CGFloat dashPattern[] = {2,4, 6};
                [path setLineDash:dashPattern count:3 phase:1];
                
                [path stroke];
                
            }else{
                
                
                //Get the best anchor for both Components
                //outComp.center
                //insideComp.center
                
                CGPoint outAnchor = [self getBestAnchorForComponent:outComp toPoint:insideComp.center];
                CGPoint insAnchor = [self getBestAnchorForComponent:insideComp toPoint:outComp.center];
                
                
                UIBezierPath * path = [[UIBezierPath alloc] init];
                [[UIColor blackColor] setStroke];
                
                [path setLineWidth:2.0];
                
                [path moveToPoint:outAnchor];
                [path addLineToPoint:insAnchor];
                
                [path stroke];
                
                CGPoint left;
                CGPoint right;
                
                if(outAnchor.x < insAnchor.x){
                    //out está a la izquierda
                    left = outAnchor;
                    right = insAnchor;
                }else{
                    //ins está a la izquierda
                    left = insAnchor;
                    right = outAnchor;
                }
                
                UIColor * color =nil;
                UIFont * font = nil;
                //If we are drawing the selected connection change color and font
                if(inside == dele.selectedConnection){
                    color = [UIColor redColor];
                    font = [UIFont fontWithName:@"Helvetica Bold" size:15.0];
                }else{
                    color = [UIColor blackColor];
                    font = [UIFont fontWithName:@"Helvetica" size:12.0];
                }
                
                NSDictionary * dic = @{NSForegroundColorAttributeName: color, NSFontAttributeName: font};
                NSAttributedString * str = [[NSAttributedString alloc] initWithString:inside.name attributes:dic];
                
                
                CGSize strSize = [str size];
                
                
                
                //[str drawAtPoint:CGPointMake(z, 5)];
                double w = fabs(right.x - left.x);
                double h;
                
                //if(left.y < right.y)
                //   h = abs(right.y - left.y);
                //else
                h = left.y - right.y;
                h = fabs(h);
                
                double b = (w - strSize.width)/2.0;
                double e = (h - strSize.height)/2.0;
                
                double y;
                if(left.y < right.y){
                    y = left.y;
                }else{
                    y = right.y;
                }
                
                
                [str drawAtPoint:CGPointMake(left.x +b + xmargin, y + e - ymargin)];
                
                [[UIColor blackColor]setFill];
                [[UIColor blackColor]setStroke];
                
                CGRect strRect = CGRectMake(left.x + b + xmargin, y+e -ymargin, str.size.width, str.size.height);
                
                inside.touchRect = strRect;
                
                
                self.transform = CGAffineTransformIdentity;
                
                
                // calculate the position of the arrow
                CGPoint arrowMiddle;
                arrowMiddle.x = (outAnchor.x + insAnchor.x) / 2 ;
                arrowMiddle.y = (outAnchor.y + insAnchor.y) / 2 ;
                
                // create a line vector
                CGPoint v;
                v.x = insAnchor.x - outAnchor.x;
                v.y = insAnchor.y - outAnchor.y;
                
                // normalize it and multiply by needed length
                CGFloat length = sqrt(v.x * v.x + v.y * v.y);
                v.x = 10 * (v.x / length);
                v.y = 10 * (v.y / length);
                
                // turn it by 120° and offset to position
                CGPoint arrowLeft = CGPointApplyAffineTransform(v, CGAffineTransformMakeRotation(3.14 * 2 / 3));
                arrowLeft.x = arrowLeft.x + arrowMiddle.x;
                arrowLeft.y = arrowLeft.y + arrowMiddle.y;
                
                self.transform = CGAffineTransformIdentity;
                
                // turn it by -120° and offset to position
                CGPoint arrowRight = CGPointApplyAffineTransform(v, CGAffineTransformMakeRotation(-3.14 * 2 / 3));
                arrowRight.x = arrowRight.x + arrowMiddle.x;
                arrowRight.y = arrowRight.y + arrowMiddle.y;
                
                UIBezierPath * arrow = [[UIBezierPath alloc] init];
                [arrow moveToPoint:insAnchor];
                [arrow addLineToPoint:arrowRight];
                [arrow addLineToPoint:arrowLeft];
                [arrow addLineToPoint:insAnchor];
                [arrow fill];
                
                
                
            }
            
        }
    }*/
}

@end
