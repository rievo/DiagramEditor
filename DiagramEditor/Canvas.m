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


#define curveMove 60


#define radius 35

#define radiansToDegrees( radians ) ( ( radians ) * ( 180.0 / M_PI ) )


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
    
    
    NSArray *viewsToRemove = [self subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    
    [self setNeedsDisplay];
}


-(void)handleTap: (UITapGestureRecognizer *)recog{
    Connection * conn;
    
    CGPoint p = [recog locationInView:self];
    
    for(int i = 0; i< dele.connections.count; i++){
        conn = [dele.connections objectAtIndex:i];
        
        if([self isPoint:p withinDistance:10.0 ofPath:conn.arrowPath.CGPath]){
            [[NSNotificationCenter defaultCenter]postNotificationName:@"showConnNot" object: conn];
        }
    }
}


-(CGPoint) getAnchorPointFromComponent: (Component *)c1
                           toComponent: (Component *)c2
                             andRadius: (float)r{
    CGPoint temp;
    
    
    CGPoint sourcep = c1.center;
    CGPoint targetp = c2.center;
    
    double angle = atan2(targetp.y- sourcep.y, targetp.x - sourcep.x);
    
    double x = r * cos(angle);
    double y = r * sin(angle);
    
    x =  c1.center.x  +x ;
    y =  c1.center.y  +y ;
    
    temp.x = x;
    temp.y = y;
    
    return temp;
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
    
    
    Component * compOut = nil;
    Component * compIns = nil;
    Connection * conn = nil;
    for(int i = 0; i< dele.components.count; i++){
        compOut = [dele.components objectAtIndex:i];
        
        
        for (int j = i+1; j<dele.components.count; j++){
            compIns = [dele.components objectAtIndex:j];
            
            //Tengo out & ins
            //Recorro todas las conexiones contando
            
            NSMutableArray * connectionsBetweenOutAndIns = [[NSMutableArray alloc] init];
            
            int count = 0;
            
            for(int c = 0; c< dele.connections.count; c++){
                conn = [dele.connections objectAtIndex:c];
                BOOL flag = false;
                
                if((conn.source == compOut && conn.target == compIns)){
                    flag = true;
                    count ++;
                }
                
                if((conn.source == compIns && conn.target == compOut)){
                    flag = true;
                    count ++;
                }
                
                if(flag == true){
                    [connectionsBetweenOutAndIns addObject:conn];
                }
            }
            
            
            NSLog(@"%@", [NSString stringWithFormat:@"count: %d    .count: %lu", count, (unsigned long)connectionsBetweenOutAndIns.count]);
            //En count tengo el nº de conexiones que hay
            //En connectionsBetweenOutAndIns tengo esas conexiones
            
            for(int c = 0; c < connectionsBetweenOutAndIns.count; c++){
                conn = [connectionsBetweenOutAndIns objectAtIndex:c];
                CGPoint sourceAnchor = [self getAnchorPointFromComponent:conn.source toComponent:conn.target andRadius:radius];
                CGPoint targetAnchor = [self getAnchorPointFromComponent:conn.target toComponent:conn.source andRadius:radius];
                
                //VPunto medio
                float xm = (sourceAnchor.x + targetAnchor.x)/2 ;
                float ym = (sourceAnchor.y + targetAnchor.y)/2 ;
                
                //vector v
                float vx = xm -sourceAnchor.x ;
                float vy = ym -sourceAnchor.y ;
                
                
                
                //vector n
                float nx = -vy/2;
                float ny = vx /2;
                
                
                //point w
                float wx =  nx +xm;
                float wy =  ny +ym;
                
                
                //point z
                float zx = -nx +xm;
                float zy = -ny +ym;
                
                
                //Vector unitario, t va de w a z
                float tx = zx -wx;
                float ty = zy - wy;
                
                float modulet = sqrtf(pow(tx, 2) + pow(ty, 2));
                float div = modulet / (count-1);
                
                float px = wx + (tx*div*c/modulet);
                float py = wy + (ty*div*c/modulet);
                
                if(count == 1){
                    px = xm;
                    py = ym;
                }
                
                //El bezier path va a pasar por px, py
                
                UIBezierPath * line  = [[UIBezierPath alloc] init];
                [line moveToPoint:sourceAnchor];
                [line addQuadCurveToPoint:targetAnchor controlPoint:CGPointMake(px, py)];
                [line setLineWidth:1.0];
                [[UIColor blackColor]setStroke];
                [line stroke];
                conn.arrowPath = line;
                
                
                
                //Draw decorator
                UIImage * test = [UIImage imageNamed:@"inputFillArrow"];
                
                test = [UIImage imageWithCGImage:[test CGImage]
                                           scale:2.0
                                     orientation:test.imageOrientation];
                //Calculamos los grados entre el punto de control (px,py) y el target
                
                float angle = atanf((targetAnchor.y-py)/ (targetAnchor.x-px));
                if(px > targetAnchor.x) {
                    angle += M_PI;
                }
                NSLog(@"%@", [NSString stringWithFormat:@"%.2f", angle]);

                //float degrees = radiansToDegrees(angle);
                
                //Rotamos test los ángulos que sean
                test = [self imageRotatedByDegrees:test rads:angle];
                [test drawAtPoint:CGPointMake(targetAnchor.x - test.size.width/2 , targetAnchor.y -test.size.height/2 )];
                
                
                //Dibujamos un punto amarillo solo para ver el targetanchor
                UIBezierPath * point = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(targetAnchor.x-2, targetAnchor.y-2, 4, 4)];
                [[UIColor redColor]setFill];
                [point fill];
                
            }
            
        }
    }
    
    
    //
    //            UIColor * color =nil;
    //            UIFont * font = nil;
    //
    //            color = [UIColor blackColor];
    //            font = [UIFont fontWithName:@"Helvetica" size:12.0];
    //
    //
    //            NSDictionary * dic = @{NSForegroundColorAttributeName: color, NSFontAttributeName: font};
    //            NSAttributedString * str = [[NSAttributedString alloc] initWithString:conn.name attributes:dic];
    //
    //
    //            CGSize strSize = [str size];
    //
    //
    //
    //            //[str drawAtPoint:CGPointMake(z, 5)];
    //            double w = fabs(right.x - left.x);
    //            h = 0;
    //
    //            //if(left.y < right.y)
    //            //   h = abs(right.y - left.y);
    //            //else
    //            h = left.y - right.y;
    //            h = fabs(h);
    //
    //            double b = (w - strSize.width)/2.0;
    //            double e = (h - strSize.height)/2.0;
    //
    //            double y;
    //            if(left.y < right.y){
    //                y = left.y;
    //            }else{
    //                y = right.y;
    //            }
    //
    //
    //            [str drawAtPoint:CGPointMake(left.x +b + xmargin, y + e - ymargin)];
    //
    //
    //
    //            CGRect strRect = CGRectMake(left.x + b + xmargin, y+e -ymargin, str.size.width, str.size.height);
    //
    //            conn.touchRect = strRect;
    //
    //
    //    
    if(xArrowStart> 0 && yArrowStart> 0){
        
        UIBezierPath * line = [[UIBezierPath alloc] init];
        [line setLineWidth:2.0];
        [dele.blue3 setStroke];
        [line moveToPoint:CGPointMake(xArrowStart, yArrowStart)];
        [line addLineToPoint:CGPointMake(xArrowEnd, yArrowEnd)];
        [line stroke];
        
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


#pragma mark rotate PNG
- (UIImage *)imageRotatedByDegrees:(UIImage*)oldImage rads:(CGFloat)rads{
    //Calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,oldImage.size.width, oldImage.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(rads);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    //Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    //Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //Rotate the image context
    CGContextRotateCTM(bitmap, rads);
    
    //Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-oldImage.size.width / 2, -oldImage.size.height / 2, oldImage.size.width, oldImage.size.height), [oldImage CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end
