//
//  Canvas.m
//  DiagramEditor
//
//  Created by Diego Vaquero Melchor on 9/12/15.
//  Copyright © 2015 Diego Vaquero Melchor. All rights reserved.
//

#import "Canvas.h"
#import "Connection.h"
#import "ClassAttribute.h"
#import "Constants.h"
#import <CoreGraphics/CoreGraphics.h>
#import "Alert.h"

#import "DrawnAlert.h"

#define pi 3.14159265359


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
    
    highlightColor = [UIColor colorWithRed:210/255.0 green:144/255.0 blue:212/255.0 alpha:0.5];
    
    dele = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    fontColor = [UIColor blackColor];
    font = [UIFont fontWithName:@"Helvetica" size:10.0];
    
    xArrowStart = -1.0;
    yArrowStart = -1.0;
    
    self.backgroundColor = [dele blue0];
    

    
    [self setUserInteractionEnabled:YES];
    
     self.backgroundColor = [UIColor colorWithRed:218/255.0 green:224/255.0 blue:235/255.0 alpha:0.6];
    
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
        
        if([self isPoint:p withinDistance:20.0 ofPath:conn.arrowPath.CGPath]){
            [[NSNotificationCenter defaultCenter]postNotificationName:@"showConnNot" object: conn];
        }
    }
    
    
    
    dele.selectedDrawn = nil;
    [dele.yonv removeFromSuperview];
    dele.yonv = nil;
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"repaintCanvas" object: nil];
    //Check if touch is in some path
    for(DrawnAlert * da in dele.drawnsArray){
        if([self isPoint:p withinDistance:30.0 ofPath:da.path.CGPath] == YES){
            
            //If I created this alert
            if([da.who.displayName isEqualToString:dele.myPeerInfo.peerID.displayName]){
                NSLog(@"TOUCHING");
                dele.selectedDrawn = da;
                [[NSNotificationCenter defaultCenter]postNotificationName:@"repaintCanvas" object: nil];
                
                //TODO: Show delete button
                dele.yonv = [[[NSBundle mainBundle] loadNibNamed:@"YesOrNoView"
                                                           owner:self
                                                         options:nil] objectAtIndex:0];
                dele.yonv.delegate = self;
                dele.yonv.al = da;
                //[dele.yonv setCenter:p];
                [dele.yonv setFrame:CGRectMake(p.x -dele.yonv.frame.size.width/2,
                                               p.y -dele.yonv.frame.size.height/2,
                                               dele.yonv.frame.size.width,
                                               dele.yonv.frame.size.height)];
                [self addSubview:dele.yonv];
                
            
                return;
            }

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
    
    /*//Draw background
     UIBezierPath * back = [UIBezierPath bezierPathWithRect:self.frame];
     [[dele blue0]setFill];
     [back fill];*/
    
    
    //Draw rectangle on fingered component
    
    UIBezierPath * fingeredPath = [UIBezierPath bezierPathWithRoundedRect:dele.fingeredComponent.frame cornerRadius:1.0];
    [fingeredPath setLineWidth:0];
    [highlightColor setFill];
    [fingeredPath fill];
    
    
    Component * compOut = nil;
    Component * compIns = nil;
    Connection * conn = nil;
    for(int i = 0; i< dele.components.count; i++){
        compOut = [dele.components objectAtIndex:i];
        
        
        for (int j = i+1; j<dele.components.count; j++){
            compIns = [dele.components objectAtIndex:j];
            
            [compIns updateNameLabel];
            
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
            
            
            //NSLog(@"%@", [NSString stringWithFormat:@"count: %d    .count: %lu", count, (unsigned long)connectionsBetweenOutAndIns.count]);
            //En count tengo el nº de conexiones que hay
            //En connectionsBetweenOutAndIns tengo esas conexiones
            CGPoint aux_sourceAnchor = [self getAnchorPointFromComponent:compOut toComponent:compIns andRadius:defradius + compOut.frame.size.width/2];
            CGPoint aux_targetAnchor = [self getAnchorPointFromComponent:compIns toComponent:compOut andRadius:defradius + compIns.frame.size.width/2];
            
            //VPunto medio
            float xm = (aux_sourceAnchor.x + aux_targetAnchor.x)/2 ;
            float ym = (aux_sourceAnchor.y + aux_targetAnchor.y)/2 ;
            
            //vector v
            float vx = xm -aux_sourceAnchor.x ;
            float vy = ym -aux_sourceAnchor.y ;
            
            
            
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
            
            float margin = 3;
            
            
            for(int c = 0; c < connectionsBetweenOutAndIns.count; c++){
                conn = [connectionsBetweenOutAndIns objectAtIndex:c];
                
                
                
                //Línea
                CGPoint lineStart = [self getAnchorPointFromComponent:conn.source toComponent:conn.target andRadius:margin + defradius + conn.source.frame.size.width / 2 + decoratorSize];
                CGPoint lineEnd = [self getAnchorPointFromComponent:conn.target toComponent:conn.source andRadius:margin + defradius + conn.target.frame.size.width / 2 + decoratorSize];
                
                
                //Decorators
                CGPoint sourceAnchor = [self getAnchorPointFromComponent:conn.source toComponent:conn.target andRadius:margin + defradius + conn.source.frame.size.width / 2 ];
                CGPoint targetAnchor = [self getAnchorPointFromComponent:conn.target toComponent:conn.source andRadius:margin + defradius + conn.target.frame.size.width / 2 ];
                
                float px = wx + (tx*div*c/modulet);
                float py = wy + (ty*div*c/modulet);
                
                if(count == 1){
                    px = xm;
                    py = ym;
                }
                
                //El bezier path va a pasar por px, py
                CGPoint controlPoint = CGPointMake(px, py);
                UIBezierPath * line  = [[UIBezierPath alloc] init];
                [line moveToPoint:lineStart];
                [line addQuadCurveToPoint:lineEnd controlPoint:controlPoint];
                
                
                if(conn.lineWidth == nil){
                    [line setLineWidth:2.0];
                }else{
                    [line setLineWidth:conn.lineWidth.floatValue];
                }
                
                
                
                
                if(conn.lineColor == nil){
                    [[UIColor redColor]setStroke];
                }else{
                    [conn.lineColor setStroke];
                }
                
                
                
                if([conn.lineStyle isEqualToString:SOLID]){
                    
                }else if([conn.lineStyle isEqualToString:DASH]){
                    CGFloat dashes[] = {10 , 10};
                    [line setLineDash:dashes count:2 phase:0];
                }else if([conn.lineStyle isEqualToString:DOT]){
                    CGFloat dashes[] = {2,5};
                    [line setLineDash:dashes count:2 phase:0];
                    
                }else if([conn.lineStyle isEqualToString:DASH_DOT]){
                    CGFloat dashes[] = {2,10,10,10};
                    [line setLineDash:dashes count:4 phase:0];
                }else{
                    conn.lineStyle = SOLID;
                }
                
                [line stroke];
                //[line fill];
                conn.arrowPath = line;
                conn.controlPoint = controlPoint;
                
                
                
                //Draw decorator
                //Calculamos los grados entre el punto de control (px,py) y el target
                
                float angle = atanf((targetAnchor.y-py)/ (targetAnchor.x-px));
                if(px > targetAnchor.x) {
                    angle += M_PI;
                }
                
                
                //Decorators
                UIBezierPath * pathTarget = [[UIBezierPath alloc]init];
                UIBezierPath * pathSource = [[UIBezierPath alloc]init];
                
                
                float halfDec = decoratorSize/2;
                
                [[UIColor redColor]setStroke];
                [[UIColor redColor]setFill];
                
                //Target
                
                if([conn.targetDecorator isEqualToString:NO_DECORATION]){
                    //pathTarget = [Canvas getNoDecoratorPath];
                    pathTarget = nil;
                }else if([conn.targetDecorator isEqualToString:INPUT_ARROW]){
                    
                    pathTarget = [Canvas getInputArrowPath];
                    
                }else if([conn.targetDecorator isEqualToString:DIAMOND]){
                    
                    pathTarget = [Canvas getDiamondPath];
                }else if([conn.targetDecorator isEqualToString:FILL_DIAMOND]){
                    
                    pathTarget = [Canvas getDiamondPath];
                }else if([conn.targetDecorator isEqualToString:INPUT_CLOSED_ARROW]){
                    pathTarget = [Canvas getInputClosedArrowPath];
                }else if([conn.targetDecorator isEqualToString:INPUT_FILL_CLOSED_ARROW]){
                    pathTarget = [Canvas getInputFillClosedArrowPath];
                }else if([conn.targetDecorator isEqualToString:OUTPUT_ARROW]){
                    pathTarget = [Canvas getOutputArrowPath];
                    
                }else if([conn.targetDecorator isEqualToString:OUTPUT_CLOSED_ARROW]){
                    
                    pathTarget = [Canvas getOutputClosedArrowPath];
                }else if([conn.targetDecorator isEqualToString:OUTPUT_FILL_CLOSED_ARROW]){
                    pathTarget = [Canvas getOutputClosedArrowPath];
                }else{ //No decorator
                    //pathTarget = [Canvas getNoDecoratorPath];
                    pathTarget = nil;
                }
                
                
                if(pathTarget != nil){
                    
                    CGAffineTransform transformTarget = CGAffineTransformIdentity;
                    transformTarget = CGAffineTransformConcat(transformTarget, CGAffineTransformMakeRotation(angle));
                    transformTarget = CGAffineTransformConcat(transformTarget, CGAffineTransformMakeTranslation(lineEnd.x +(cos(angle)*halfDec - sin(angle)*0 ),
                                                                                                                lineEnd.y +(sin(angle)*halfDec + cos(angle)*0 )));
                    [pathTarget applyTransform:transformTarget];
                    
                    [conn.lineColor setStroke];
                    [conn.lineColor setFill];
                    
                    
                    [pathTarget stroke];
                    if([conn.targetDecorator isEqualToString:FILL_DIAMOND] ||
                       [conn.targetDecorator isEqualToString:INPUT_FILL_CLOSED_ARROW] ||
                       [conn.targetDecorator isEqualToString:OUTPUT_FILL_CLOSED_ARROW]){
                        [pathTarget fill];
                    }
                    
                }
                

                
                //Source, igual que el target, pero cambia el punto de la transformación
                
                
                if([conn.targetDecorator isEqualToString:NO_DECORATION]){
                    //pathSource = [Canvas getNoDecoratorPath];
                    pathSource = nil;
                }else if([conn.sourceDecorator isEqualToString:INPUT_ARROW]){
                    
                    pathSource = [Canvas getInputArrowPath];
                    
                }else if([conn.sourceDecorator isEqualToString:DIAMOND]){
                    pathSource = [Canvas getDiamondPath];
                }else if([conn.sourceDecorator isEqualToString:FILL_DIAMOND]){
                    pathSource = [Canvas getDiamondPath];
                    
                }else if([conn.sourceDecorator isEqualToString:INPUT_CLOSED_ARROW]){
                    pathSource = [Canvas getInputClosedArrowPath];
                    
                }else if([conn.sourceDecorator isEqualToString:INPUT_FILL_CLOSED_ARROW]){
                    pathSource = [Canvas getInputFillClosedArrowPath];
                    
                }else if([conn.sourceDecorator isEqualToString:OUTPUT_ARROW]){
                    pathSource = [Canvas getOutputArrowPath];
                    
                }else if([conn.sourceDecorator isEqualToString:OUTPUT_CLOSED_ARROW]){
                    pathSource = [Canvas getOutputClosedArrowPath];
                }else if([conn.sourceDecorator isEqualToString:OUTPUT_FILL_CLOSED_ARROW]){
                    pathSource = [Canvas getOutputClosedArrowPath];
                }else{ //No decorator
                    pathSource = [Canvas getNoDecoratorPath];
                    pathSource = nil;
                }
                
                
                if(pathSource != nil){
                    CGAffineTransform transformSource = CGAffineTransformIdentity;
                    transformSource = CGAffineTransformConcat(transformSource, CGAffineTransformMakeRotation(angle + M_PI));
                    transformSource = CGAffineTransformConcat(transformSource,
                                                              CGAffineTransformMakeTranslation(lineStart.x +(cos(angle +M_PI)*halfDec - sin(angle+M_PI)*0 ),
                                                                                               lineStart.y +(sin(angle+M_PI)*halfDec + cos(angle+M_PI)*0 )));
                    [pathSource applyTransform:transformSource];
                    
                    
                    [conn.lineColor setStroke];
                    [conn.lineColor setFill];
                    
                    
                    [pathSource stroke];
                    if([conn.sourceDecorator isEqualToString:FILL_DIAMOND] ||
                       [conn.sourceDecorator isEqualToString:INPUT_FILL_CLOSED_ARROW] ||
                       [conn.sourceDecorator isEqualToString:OUTPUT_FILL_CLOSED_ARROW]){
                        [pathSource fill];
                    }
                }
                
                
                
            }
            
        }
    }
    
    
    //Dibujamos las conexiones entre un elemento y él mismo
    
    Component * comp = nil;
    conn = nil;
    for(int i = 0; i<dele.components.count; i++){
        comp = [dele.components objectAtIndex:i];
        //Para cada nodo, recorremos las conexiones y contamos cuántas tiene con origen y destino él mismo
        
        NSMutableArray * selfConnections = [[NSMutableArray alloc] init];
        
        for(int c = 0; c < dele.connections.count;c++){
            conn = [dele.connections objectAtIndex:c];
            if(conn.source == conn.target && conn.source == comp){
                //Self-connection
                [selfConnections addObject:conn];
            }
        }
        
        //Self-connection has those connections that we must draw
        float h2 = comp.frame.size.height / 2;
        float div = h2/(selfConnections.count -1)/2;
        
        if(selfConnections.count == 1){
            UIBezierPath * arc = [UIBezierPath bezierPathWithArcCenter:CGPointMake(comp.frame.origin.x, comp.frame.origin.y + comp.frame.size.height)
                                                                radius:h2
                                                            startAngle:0
                                                              endAngle:DEGREES_TO_RADIANS(270)
                                                             clockwise:YES];
            conn = [selfConnections objectAtIndex:0];
            [arc setLineWidth:0.8];
            //[[UIColor blackColor]setStroke];
            [conn.lineColor setStroke];
            [arc stroke];
            conn.arrowPath = arc;
        }else{
            for(int c = 0; c < selfConnections.count; c++){
                conn = [selfConnections objectAtIndex:c];
                UIBezierPath * arc = [UIBezierPath bezierPathWithArcCenter:CGPointMake(comp.frame.origin.x, comp.frame.origin.y+ comp.frame.size.height)
                                                                    radius:h2 - (div * c)
                                                                startAngle:0
                                                                  endAngle:DEGREES_TO_RADIANS(270)
                                                                 clockwise:YES];
                
                [arc setLineWidth:0.8];
                //[[UIColor blackColor]setStroke];
                [conn.lineColor setStroke];
                [arc stroke];
                conn.arrowPath = arc;
                
            }
        }
    }
    
    
    /*
    
    NSDictionary * dic = @{NSForegroundColorAttributeName: fontColor,
                           NSFontAttributeName: font};
    
    //Draw connections name
    
    for(int c = 0; c < dele.connections.count;c++){
        conn = [dele.connections objectAtIndex:c];
        
        if(conn.source != conn.target){
            NSAttributedString * str = [[NSAttributedString alloc] initWithString: [conn getName]
                                                                       attributes:dic];
            
            
            CGSize strSize = [str size];
            
            
            float halfw = strSize.width / 2;
            
            
            CGPoint sourceAnchor = [self getAnchorPointFromComponent:conn.source toComponent:conn.target andRadius:defradius + conn.source.frame.size.width / 2];
            CGPoint targetAnchor = [self getAnchorPointFromComponent:conn.target toComponent:conn.source andRadius:defradius + conn.target.frame.size.width / 2];
            
            
            CGPoint strpoint = CGPointMake(QuadBezier(0.5,sourceAnchor.x, conn.controlPoint.x, targetAnchor.x), QuadBezier(0.5, sourceAnchor.y, conn.controlPoint.y, targetAnchor.y));
            
            
            [str drawAtPoint:CGPointMake( strpoint.x - halfw, strpoint.y-5)];
        }
        
        
    }
    
    
    
    */
    
    
    
    
    
    if(dele.showingAnnotations == YES){
        
        //Draw connections between notes and components
        for(Alert * al in dele.notesArray){
            if(al.associatedComponent != nil){
                UIBezierPath * link = [[UIBezierPath alloc] init];
                [dele.blue4 setStroke];
                [link moveToPoint:al.center];
                [link addLineToPoint:al.associatedComponent.center];
                [link stroke];
            }
        }
        
        //Draw hand-made draws
        for(DrawnAlert * da in dele.drawnsArray){
            
            if(da == dele.selectedDrawn){
                [[UIColor purpleColor]setStroke];
            }else{
                //[dele.blue3 setStroke];
                [da.color setStroke];
            }
            
            [da.path stroke];
            
        }
    }
    
    
    if(xArrowStart> 0 && yArrowStart> 0){
        
        UIBezierPath * line = [[UIBezierPath alloc] init];
        [line setLineWidth:2.0];
        [dele.blue3 setStroke];
        [line moveToPoint:CGPointMake(xArrowStart, yArrowStart)];
        [line addLineToPoint:CGPointMake(xArrowEnd, yArrowEnd)];
        [line stroke];
        
    }
    
    
    
}


float QuadBezier(float t, float start, float c1, float end)
{
    CGFloat t_ = (1.0 - t);
    CGFloat tt_ = t_ * t_;
    CGFloat tt = t * t;
    
    return start * tt_
    + 2.0 *  c1 * t_ * t
    + end * tt;
}

- (void) repaintCanvas : (NSNotification *) notification {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        Component * temp = nil;
        for(int i = 0; i<dele.components.count; i++){
            temp = [dele.components objectAtIndex:i];
            NSString * label = @"";
            
            for(ClassAttribute * atr in  temp.attributes){
                
                if(atr.isLabel){
                    label = [label stringByAppendingString:atr.currentValue];
                }
            }
            temp.textLayer.string = label;
            [temp updateNameLabel];
            
            [temp setNeedsDisplay];
        }
        
        [self setNeedsDisplay];
    });
    
    
}


- (BOOL)isPoint:(CGPoint)p withinDistance:(CGFloat)distance ofPath:(CGPathRef)path
{
    CGPathRef hitPath = CGPathCreateCopyByStrokingPath(path, NULL, distance*2, kCGLineCapRound, kCGLineJoinRound, 0);
    BOOL isWithinDistance = CGPathContainsPoint(hitPath, NULL, p, false);
    return isWithinDistance;
}


#pragma mark rotate PNG
/*- (UIImage *)imageRotatedByDegrees:(UIImage*)oldImage rads:(CGFloat)rads{
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
 }*/


#pragma mark Paths for decorators
+(UIBezierPath *)getInputArrowPath{
    UIBezierPath * path = [[UIBezierPath alloc]init];
    float halfDec = decoratorSize / 2.0;
    
    
    [path moveToPoint:CGPointMake(0 -halfDec, 0-halfDec)];
    [path addLineToPoint:CGPointMake(decoratorSize-halfDec , halfDec-halfDec)];
    [path addLineToPoint:CGPointMake(0-halfDec, decoratorSize-halfDec)];
    [path moveToPoint:CGPointMake(decoratorSize-halfDec,halfDec-halfDec)];
    [path addLineToPoint:CGPointMake(0-halfDec, halfDec-halfDec)];
    
    
    
    [path setLineWidth:lineWitdh];
    
    
    return path;
}
/*
 -(UIBezierPath *)getInputArrowPath{
 UIBezierPath * path = [[UIBezierPath alloc]init];
 float halfDec = decoratorSize / 2.0;
 return path;
 }*/
+(UIBezierPath *)getDiamondPath{
    UIBezierPath * path = [[UIBezierPath alloc]init];
    float halfDec = decoratorSize / 2.0;
    
    [path moveToPoint:CGPointMake(0 -halfDec, halfDec-halfDec)];
    [path addLineToPoint:CGPointMake(halfDec -halfDec, decoratorSize-halfDec)];
    [path addLineToPoint:CGPointMake(decoratorSize -halfDec , halfDec -halfDec)];
    [path addLineToPoint:CGPointMake(halfDec-halfDec, 0-halfDec)];
    [path closePath];
    [path setLineWidth:lineWitdh];
    
    return path;
}



+(UIBezierPath *)getInputClosedArrowPath{
    UIBezierPath * path = [[UIBezierPath alloc]init];
    float halfDec = decoratorSize / 2.0;
    
    [path moveToPoint:CGPointMake(0 -halfDec,0 -halfDec)];
    [path addLineToPoint:CGPointMake(decoratorSize -halfDec, halfDec-halfDec)];
    [path addLineToPoint:CGPointMake(0 -halfDec , decoratorSize -halfDec)];
    
    [path closePath];
    [path setLineWidth:lineWitdh];
    
    return path;
}
+(UIBezierPath *)getInputFillClosedArrowPath{
    UIBezierPath * path = [[UIBezierPath alloc]init];
    float halfDec = decoratorSize / 2.0;
    
    [path moveToPoint:CGPointMake(0 -halfDec,0 -halfDec)];
    [path addLineToPoint:CGPointMake(decoratorSize -halfDec, halfDec-halfDec)];
    [path addLineToPoint:CGPointMake(0 -halfDec , decoratorSize -halfDec)];
    
    [path closePath];
    [path setLineWidth:lineWitdh];
    
    return path;
}

+(UIBezierPath *)getOutputArrowPath{
    UIBezierPath * path = [[UIBezierPath alloc]init];
    float halfDec = decoratorSize / 2.0;
    [path moveToPoint:CGPointMake(decoratorSize-halfDec, 0 -halfDec)];
    [path addLineToPoint:CGPointMake(0 -halfDec, halfDec-halfDec)];
    [path addLineToPoint:CGPointMake(decoratorSize -halfDec , decoratorSize -halfDec)];
    [path setLineWidth:lineWitdh];
    
    
    return path;
}

+(UIBezierPath *)getOutputClosedArrowPath{
    UIBezierPath * path = [[UIBezierPath alloc]init];
    float halfDec = decoratorSize / 2.0;
    [path moveToPoint:CGPointMake(decoratorSize-halfDec, 0 -halfDec)];
    [path addLineToPoint:CGPointMake(0 -halfDec, halfDec-halfDec)];
    [path addLineToPoint:CGPointMake(decoratorSize -halfDec , decoratorSize -halfDec)];
    [path setLineWidth:lineWitdh];
    [path closePath];
    
    return path;
}

+(UIBezierPath *)getNoDecoratorPath{
    UIBezierPath * path = [[UIBezierPath alloc]init];
    float halfDec = decoratorSize / 2.0;
    [path moveToPoint:CGPointMake(0 -halfDec, halfDec-halfDec)];
    [path addLineToPoint:CGPointMake(decoratorSize-halfDec, halfDec-halfDec)];
    [path setLineWidth:lineWitdh];
    
    return path;
}


#pragma mark YesOrNoDelegate
-(void)confirmDeleteDrawnAlert:(DrawnAlert *)alert{
    
    [dele.drawnsArray removeObject:alert];
    [self setNeedsDisplay];
    
    //Send delete alert to peers
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    
    [dic setObject:alert forKey:@"drawn"];
    [dic setObject:kDeleteDrawn forKey:@"msg"];
    [dic setObject:dele.myPeerInfo.peerID forKey:@"who"];
    
    NSError * error = nil;
    
    NSData * allData = [NSKeyedArchiver archivedDataWithRootObject:dic];
    [dele.manager.session sendData:allData
                           toPeers:dele.manager.session.connectedPeers
                          withMode:MCSessionSendDataReliable
                             error:&error];
}

@end
