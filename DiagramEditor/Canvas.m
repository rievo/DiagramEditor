//
//  Canvas.m
//  DiagramEditor
//
//  Created by Diego Vaquero Melchor on 9/12/15.
//  Copyright © 2015 Diego Vaquero Melchor. All rights reserved.
//

#import "Canvas.h"
#import "Connection.h"

#define xmargin 15
#define ymargin 10

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(repaintCanvas:)
                                                 name:@"repaintCanvas" object:nil];

    
    tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:tapGR];
}


-(void)handleTap: (UITapGestureRecognizer *)recog{
    Connection * conn;
    
    CGPoint p = [recog locationInView:self];
    //NSLog(@"x: %.2f  y: %.2f", p.x, p.y);
    for(int i = 0; i< dele.connections.count; i++){
        conn = [dele.connections objectAtIndex:i];
        //if([conn.arrowPath containsPoint:p]){
        if([self isPoint:p withinDistance:10.0 ofPath:conn.arrowPath.CGPath]){
            NSLog(@"TOCADOOO ACHO");
            [[NSNotificationCenter defaultCenter]postNotificationName:@"showConnNot" object: conn];
        }
    }
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
    
    
    Connection * conn = nil;
    for(int i = 0; i< dele.connections.count; i++){
        conn = [dele.connections objectAtIndex:i];
        
        if(conn.source == conn.target){
            
        }else{
            //Get the best anchor for both Components
            //outComp.center
            //insideComp.center
            
            CGPoint sourceAnchor = [self getBestAnchorForComponent:conn.source toPoint:conn.target.center];
            CGPoint targetAnchor = [self getBestAnchorForComponent:conn.target toPoint:conn.source.center];
            

            UIBezierPath * path = [[UIBezierPath alloc] init];
            [[UIColor blackColor] setStroke];
            [path setLineWidth:2.0];
            [path moveToPoint: sourceAnchor];
            CGPoint mid = CGPointMake((sourceAnchor.x + targetAnchor.x)/2.0, (sourceAnchor.y + targetAnchor.y)/2.0);
            //mid.x = mid.x -50;
            //mid.y = mid.y -50;
            [path addQuadCurveToPoint:targetAnchor controlPoint:mid];
            [path stroke];
            conn.arrowPath = path;

            
            CGPoint left;
            CGPoint right;
            
            if(sourceAnchor.x < targetAnchor.x){
                left = sourceAnchor;
                right = targetAnchor;
            }else{
                left = targetAnchor;
                right = sourceAnchor;
            }
            
            UIColor * color =nil;
            UIFont * font = nil;
            
            color = [UIColor blackColor];
            font = [UIFont fontWithName:@"Helvetica" size:12.0];
 
            
            NSDictionary * dic = @{NSForegroundColorAttributeName: color, NSFontAttributeName: font};
            NSAttributedString * str = [[NSAttributedString alloc] initWithString:conn.name attributes:dic];
            
            
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
            
         
            
            CGRect strRect = CGRectMake(left.x + b + xmargin, y+e -ymargin, str.size.width, str.size.height);
            
            conn.touchRect = strRect;
            
            
        }
    }
  }

- (void) repaintCanvas : (NSNotification *) notification {
    
    Component * temp = nil;
    for(int i = 0; i<dele.components.count; i++){
        temp = [dele.components objectAtIndex:i];
        temp.textLayer.string = temp.name;
        [temp setNeedsDisplay];
    }
    
    [self setNeedsDisplay];
}


- (BOOL)isPoint:(CGPoint)p withinDistance:(CGFloat)distance ofPath:(CGPathRef)path
{
    CGPathRef hitPath = CGPathCreateCopyByStrokingPath(path, NULL, distance*2, kCGLineCapRound, kCGLineJoinRound, 0);
    BOOL isWithinDistance = CGPathContainsPoint(hitPath, NULL, p, false);
    return isWithinDistance;
}
@end
