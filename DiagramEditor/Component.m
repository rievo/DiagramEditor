//
//  Component.m
//  DiagramEditor
//
//  Created by Diego Vaquero Melchor on 5/11/15.
//  Copyright © 2015 Diego Vaquero Melchor. All rights reserved.
//

#import "Component.h"

#import "Canvas.h"

@implementation Component


@synthesize name, connections;


NSString* const SHOW_INSPECTOR = @"ShowInspector";

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
        name = @"Class";
        
        font = [UIFont fontWithName:@"Helvetica" size:10.0];
        
        [self addTapGestureRecognizer];
        [self addLongPressGestureRecognizer];
        [self addPanGestureRecognizer];
        
        dele = [[UIApplication sharedApplication]delegate];
        
        
        connections = [[NSMutableArray alloc] init];
        
        
        
        //ShapeLayer
        backgroundLayer = [[CAShapeLayer alloc] init];
        UIBezierPath * backPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                        byRoundingCorners:UIRectCornerAllCorners
                                                              cornerRadii:CGSizeMake(5.0, 5.0)];
        backgroundLayer.frame = self.bounds;
        backgroundLayer.path = backPath.CGPath;
        backgroundLayer.fillColor = [UIColor whiteColor].CGColor;
        backgroundLayer.strokeColor = [UIColor blackColor].CGColor;
        backgroundLayer.lineWidth = 2.0;
        [self.layer addSublayer:backgroundLayer];
        
        
        
        //NameLayer
        textLayer.string = name;
        CGRect rect = CGRectMake(0, self.frame.size.height, self.frame.size.width,20);
        textLayer.frame = rect;
        textLayer.contentsScale = [UIScreen mainScreen].scale;
        [textLayer setFont:@"Helvetica-Bold"];
        [textLayer setFontSize:14];
        textLayer.alignmentMode = kCAAlignmentCenter;
        [self.layer addSublayer:textLayer];
        
        [self setNeedsDisplay];
        
        
    }
    return self;
}


#pragma mark Add Gesture Recognizer

-(void)addTapGestureRecognizer{
    tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:tapGR];
    
}


-(void)addLongPressGestureRecognizer{
    longGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    
    [longGR setMinimumPressDuration:0.5];
    [self addGestureRecognizer:longGR];
}


-(void)addPanGestureRecognizer{
    panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanComp:)];
    [self addGestureRecognizer:panGR];
}


#pragma mark Handle gestures

//Show info
//Set editing (appDelegate) and enable moving (if not)
-(void)handleTap:(UITapGestureRecognizer *)recog{
    
    //Show info popup (edge, node)
}


-  (void)handleLongPress:(UILongPressGestureRecognizer*)sender {
    
    CGPoint translatedPoint =  [sender locationInView: dele.can];
    
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        NSLog(@"Termina el long");
        [dele.can setXArrowStart: -1.0];
        [dele.can setYArrowStart:-1.0];
        [dele.can setNeedsDisplay];
        
        
        
        //Check if some component is in this point
        
        Component * selected = nil;
        Component * temp = nil;
        
        for(int i = 0; i< [dele.components count]; i++){
            temp = [dele.components objectAtIndex:i];
            //if(temp != self){

                if(CGRectContainsPoint(temp.frame, translatedPoint)){
                    selected = temp;
                }
            //}
        }
        
        if(selected == nil){
            //No hay ningún componente en ese punto, no hacemos nada
        }else{
            //Hay un componente, los unimos

        }
     
        
    }
    else if (sender.state == UIGestureRecognizerStateBegan){
        NSLog(@"Empieza el long");
        [dele.can setXArrowStart:self.center.x];
        [dele.can setYArrowStart:self.center.y];
        
        
    }else if(sender.state == UIGestureRecognizerStateChanged){
        
        [dele.can setXArrowEnd:translatedPoint.x];
        [dele.can setYArrowEnd:translatedPoint.y];
        [dele.can setNeedsDisplay];
    }
}


-(void)handlePanComp:(UIPanGestureRecognizer *)sender{
    
    CGPoint translatedPoint =  [sender locationInView: dele.can];
    
    if(sender.state == UIGestureRecognizerStateBegan){
        
    }else if(sender.state == UIGestureRecognizerStateChanged){
        //NSLog(@"moooved");
        [dele.can setNeedsDisplay];
        
        float halfW;
        float halfh;
        
        halfW = self.frame.size.width / 2;
        halfh = self.frame.size.height / 2;
        
        
        if(translatedPoint.x <  halfW)
            translatedPoint.x = halfW;
        if(translatedPoint.x > dele.can.frame.size.width - halfW)
            translatedPoint.x = dele.can.frame.size.width - halfW;
        
        if(translatedPoint.y < halfh)
            translatedPoint.y = halfh;
        if(translatedPoint.y > dele.can.frame.size.height - halfh)
            translatedPoint.y = dele.can.frame.size.height - halfh;
        
        self.center = translatedPoint;
        
    }else if(sender.state == UIGestureRecognizerStateEnded){
        [dele.can setNeedsDisplay];
    }
}


#pragma mark drawRect method
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    /*CGContextRef context = UIGraphicsGetCurrentContext();

    
    
    CGPathRef path = CGPathCreateWithRect(rect, NULL);
    [[UIColor whiteColor] setFill];
    

    
    CGContextAddPath(context, path);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    //Draw the name

    
    UIColor * color = [UIColor redColor];
    UIFont * font = [UIFont fontWithName:@"Helvetica" size:10.0];
    NSDictionary * dic = @{NSForegroundColorAttributeName: color, NSFontAttributeName: font};
    NSAttributedString * str = [[NSAttributedString alloc] initWithString:name attributes:dic];
    
    CGSize strSize = [str size];
    float z = (self.frame.size.width - strSize.width)/2;
    
    [str drawAtPoint:CGPointMake(z, 5)];
    
    UIBezierPath * bez = [[UIBezierPath alloc] init];
    [bez moveToPoint:CGPointMake(0, strSize.height +10)];
    [bez addLineToPoint:CGPointMake(self.frame.size.width, strSize.height + 10) ];
    [[UIColor blackColor]setStroke];
    [bez stroke];*/
    

}


#pragma mark Anchorpoint methods

-(CGPoint)getTopAnchorPoint{
    CGPoint temp = CGPointMake(self.frame.origin.x +  self.frame.size.width /2,
                               self.frame.origin.y);
    return temp;
}


-(CGPoint)getBotAnchorPoint{
    CGPoint temp = CGPointMake(self.frame.origin.x +  self.frame.size.width /2,
                               self.frame.origin.y + self.frame.size.height);
    return temp;
}


-(CGPoint)getRightAnchorPoint{
    CGPoint temp = CGPointMake(self.frame.origin.x +  self.frame.size.width ,
                               self.frame.origin.y + self.frame.size.height /2);
    return temp;
}



-(CGPoint)getLeftAnchorPoint{
    CGPoint temp = CGPointMake(self.frame.origin.x ,
                               self.frame.origin.y + self.frame.size.height/2);
    return temp;
}







@end
