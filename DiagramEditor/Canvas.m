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


#define xmargin 15
#define ymargin 10


#define curveMove 60


#define defradius 35

#define decoratorSize 15

#define pi 3.14159265359
#define radiansToDegrees( radians ) ( ( radians ) * ( 180.0 / M_PI ) )
#define   DEGREES_TO_RADIANS(degrees)  ((pi * degrees)/ 180)


#define lineWitdh 1.0

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
            
            
            //NSLog(@"%@", [NSString stringWithFormat:@"count: %d    .count: %lu", count, (unsigned long)connectionsBetweenOutAndIns.count]);
            //En count tengo el nº de conexiones que hay
            //En connectionsBetweenOutAndIns tengo esas conexiones
            CGPoint aux_sourceAnchor = [self getAnchorPointFromComponent:compOut toComponent:compIns andRadius:defradius];
            CGPoint aux_targetAnchor = [self getAnchorPointFromComponent:compIns toComponent:compOut andRadius:defradius];
            
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
            
            
            for(int c = 0; c < connectionsBetweenOutAndIns.count; c++){
                conn = [connectionsBetweenOutAndIns objectAtIndex:c];
                
                
                CGPoint sourceAnchor = [self getAnchorPointFromComponent:conn.source toComponent:conn.target andRadius:defradius];
                CGPoint targetAnchor = [self getAnchorPointFromComponent:conn.target toComponent:conn.source andRadius:defradius];
                
                
                
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
                //Calculamos los grados entre el punto de control (px,py) y el target
                
                float angle = atanf((targetAnchor.y-py)/ (targetAnchor.x-px));
                if(px > targetAnchor.x) {
                    angle += M_PI;
                }
                
                
                //Decorators
                UIBezierPath * pathTarget = [[UIBezierPath alloc]init];
                UIBezierPath * pathSource = [[UIBezierPath alloc]init];
                
                //TODO: Cambiar el path en función del tipo
                float halfDec = decoratorSize/2;
                
                [[UIColor redColor]setStroke];
                [[UIColor redColor]setFill];
                
                //Target
                
                if([conn.targetDecorator isEqualToString:@"NoDecoration"]){
                    pathTarget = [self getNoDecoratorPath];
                }else if([conn.targetDecorator isEqualToString:@"InputArrow"]){
                    
                    pathTarget = [self getInputArrowPath];

                }else if([conn.targetDecorator isEqualToString:@"Diamond"]){

                    pathTarget = [self getDiamondPath];
                }else if([conn.targetDecorator isEqualToString:@"FillDiamond"]){

                    pathTarget = [self getDiamondPath];
                }else if([conn.targetDecorator isEqualToString:@"InputClosedArrow"]){
                    pathTarget = [self getInputClosedArrowPath];
                }else if([conn.targetDecorator isEqualToString:@"InputFillClosedArrow"]){
                    pathTarget = [self getInputFillClosedArrowPath];
                }else if([conn.targetDecorator isEqualToString:@"OutputArrow"]){
                    pathTarget = [self getOutputArrowPath];
                    
                }else if([conn.targetDecorator isEqualToString:@"OutputClosedArrow"]){

                    pathTarget = [self getOutputClosedArrowPath];
                }else if([conn.targetDecorator isEqualToString:@"OutputFillClosedArrow"]){
                    pathTarget = [self getOutputClosedArrowPath];
                }else{ //No decorator
                    pathTarget = [self getNoDecoratorPath];
                }
                
                

                
                
                CGAffineTransform transformTarget = CGAffineTransformIdentity;
                transformTarget = CGAffineTransformConcat(transformTarget, CGAffineTransformMakeRotation(angle));
                transformTarget = CGAffineTransformConcat(transformTarget, CGAffineTransformMakeTranslation(targetAnchor.x -(cos(angle)*halfDec - sin(angle)*0 ),
                                                                                                            targetAnchor.y -(sin(angle)*halfDec + cos(angle)*0 )));
                [pathTarget applyTransform:transformTarget];
                

                
                [pathTarget stroke];
                if([conn.targetDecorator isEqualToString:@"fillDiamond"] ||
                   [conn.targetDecorator isEqualToString:@"inputFillClosedArrow"] ||
                   [conn.targetDecorator isEqualToString:@"outputFillClosedArrow"]){
                    [pathTarget fill];
                }
                
                
                //Source, igual que el target, pero cambia el punto de la transformación
                
                
                if([conn.targetDecorator isEqualToString:@"NoDecoration"]){
                    pathSource = [self getNoDecoratorPath];
                }else if([conn.sourceDecorator isEqualToString:@"InputArrow"]){
                    
                    pathSource = [self getInputArrowPath];
                    
                }else if([conn.sourceDecorator isEqualToString:@"Diamond"]){
                   pathSource = [self getDiamondPath];
                }else if([conn.sourceDecorator isEqualToString:@"FillDiamond"]){
                    pathSource = [self getDiamondPath];
                    
                }else if([conn.sourceDecorator isEqualToString:@"InputClosedArrow"]){
                    pathSource = [self getInputClosedArrowPath];
                    
                }else if([conn.sourceDecorator isEqualToString:@"InputFillClosedArrow"]){
                    pathSource = [self getInputFillClosedArrowPath];
                    
                }else if([conn.sourceDecorator isEqualToString:@"OutputArrow"]){
                    pathSource = [self getOutputArrowPath];
                    
                }else if([conn.sourceDecorator isEqualToString:@"OutputClosedArrow"]){
                   pathSource = [self getOutputClosedArrowPath];
                }else if([conn.sourceDecorator isEqualToString:@"OutputFillClosedArrow"]){
                    pathSource = [self getOutputClosedArrowPath];
                }else{ //No decorator
                   pathSource = [self getNoDecoratorPath];
                }

                CGAffineTransform transformSource = CGAffineTransformIdentity;
                transformSource = CGAffineTransformConcat(transformSource, CGAffineTransformMakeRotation(angle + M_PI));
                transformSource = CGAffineTransformConcat(transformSource,
                                                          CGAffineTransformMakeTranslation(sourceAnchor.x -(cos(angle +M_PI)*halfDec - sin(angle+M_PI)*0 ),
                                                                                           sourceAnchor.y -(sin(angle+M_PI)*halfDec + cos(angle+M_PI)*0 )));
                [pathSource applyTransform:transformSource];
                
                
                
                [pathSource stroke];
                if([conn.sourceDecorator isEqualToString:@"fillDiamond"] ||
                   [conn.sourceDecorator isEqualToString:@"inputFillClosedArrow"] ||
                   [conn.sourceDecorator isEqualToString:@"outputFillClosedArrow"]){
                [pathSource fill];
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
            [[UIColor blackColor]setStroke];
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
                [[UIColor blackColor]setStroke];
                [arc stroke];
                conn.arrowPath = arc;
                
            }
        }
    }
    
    /*
    //Dibujamos las relaciones de padre a hijo
    [[UIColor greenColor]setStroke];
    for(Component * parent in dele.components){
        for(Component * son in parent.sons){
            UIBezierPath * sonLine = [[UIBezierPath alloc] init];
            [sonLine setLineWidth:1.0];
            [sonLine moveToPoint: parent.center];
            [sonLine addLineToPoint:son.center];
            [sonLine stroke];
        }
    }*/
    
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
    
    //TODO:Quitar la envolvente mínima. Solo es para pruebas. Quitar de aquí y poner en "EditorViewController"
    //Dibujamos la envolvente mínima
    //Get min bound
    Component * minx = nil;
    Component * miny = nil;
    Component * maxx = nil;
    Component * maxy = nil;
    
    float minxW, minyW, maxxW, maxyW;
    
    for(Component * comp in dele.components){
        //First round
        if(minx == nil){
            minx = comp;
        }
        if(miny == nil){
            miny = comp;
        }
        if(maxx == nil){
            maxx = comp;
        }
        if(maxy == nil){
            maxy = comp;
        }
        
        //Let's update this
        if(comp.center.x < minx.center.x){
            minx = comp;
        }
        if(comp.center.x > maxx.center.x){
            maxx = comp;
        }
        if(comp.center.y < miny.center.y){
            miny = comp;
        }
        if(comp.center.y >maxy.center.y){
            maxy = comp;
        }
    }
    
    minxW = minx.frame.size.width / 2;
    minyW = miny.frame.size.height / 2;
    maxxW = maxx.frame.size.width / 2;
    maxyW = maxy.frame.size.height / 2;
    
    float textHeigh = 20;
    float margin = 15;
    
    UIBezierPath * outRect = [UIBezierPath bezierPathWithRect:CGRectMake(minx.center.x -minxW-margin,
                                                                      miny.center.y - minyW - textHeigh-margin,
                                                                      maxx.center.x-minx.center.x + minxW + maxxW + 2*margin,
                                                                      maxy.center.y-miny.center.y + minyW + maxyW +textHeigh+ 2*margin)];
    [[UIColor redColor]setStroke];
    [outRect setLineWidth:2.0];
    [outRect stroke];
    
}

- (void) repaintCanvas : (NSNotification *) notification {
    
    Component * temp = nil;
    for(int i = 0; i<dele.components.count; i++){
        temp = [dele.components objectAtIndex:i];
        
        for(ClassAttribute * atr in  temp.attributes){
            if([atr.name isEqualToString:@"name"]){
                temp.textLayer.string = atr.currentValue;
                [temp updateNameLabel];
            }
        }
        
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


#pragma mark Paths for decorators
-(UIBezierPath *)getInputArrowPath{
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
-(UIBezierPath *)getDiamondPath{
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

-(UIBezierPath *)getInputClosedArrowPath{
    UIBezierPath * path = [[UIBezierPath alloc]init];
    float halfDec = decoratorSize / 2.0;
    
    [path moveToPoint:CGPointMake(0 -halfDec,0 -halfDec)];
    [path addLineToPoint:CGPointMake(decoratorSize -halfDec, halfDec-halfDec)];
    [path addLineToPoint:CGPointMake(0 -halfDec , decoratorSize -halfDec)];
    
    [path closePath];
    [path setLineWidth:lineWitdh];

    return path;
}
-(UIBezierPath *)getInputFillClosedArrowPath{
    UIBezierPath * path = [[UIBezierPath alloc]init];
    float halfDec = decoratorSize / 2.0;
    
    [path moveToPoint:CGPointMake(0 -halfDec,0 -halfDec)];
    [path addLineToPoint:CGPointMake(decoratorSize -halfDec, halfDec-halfDec)];
    [path addLineToPoint:CGPointMake(0 -halfDec , decoratorSize -halfDec)];
    
    [path closePath];
    [path setLineWidth:lineWitdh];
    
    return path;
}

-(UIBezierPath *)getOutputArrowPath{
    UIBezierPath * path = [[UIBezierPath alloc]init];
    float halfDec = decoratorSize / 2.0;
    [path moveToPoint:CGPointMake(decoratorSize-halfDec, 0 -halfDec)];
    [path addLineToPoint:CGPointMake(0 -halfDec, halfDec-halfDec)];
    [path addLineToPoint:CGPointMake(decoratorSize -halfDec , decoratorSize -halfDec)];
    [path setLineWidth:lineWitdh];

    
    return path;
}

-(UIBezierPath *)getOutputClosedArrowPath{
    UIBezierPath * path = [[UIBezierPath alloc]init];
    float halfDec = decoratorSize / 2.0;
    [path moveToPoint:CGPointMake(decoratorSize-halfDec, 0 -halfDec)];
    [path addLineToPoint:CGPointMake(0 -halfDec, halfDec-halfDec)];
    [path addLineToPoint:CGPointMake(decoratorSize -halfDec , decoratorSize -halfDec)];
    [path setLineWidth:lineWitdh];
    [path closePath];
    
    return path;
}

-(UIBezierPath *)getNoDecoratorPath{
    UIBezierPath * path = [[UIBezierPath alloc]init];
    float halfDec = decoratorSize / 2.0;
    [path moveToPoint:CGPointMake(0 -halfDec, halfDec-halfDec)];
    [path addLineToPoint:CGPointMake(decoratorSize-halfDec, halfDec-halfDec)];
    [path setLineWidth:6];
    //[[UIColor redColor]setStroke];
    UIColor * col = [UIColor colorWithRed:1.0
                                    green:0
                                     blue:0
                                    alpha:0.5];
    [col setStroke];
    return path;
}


@end
