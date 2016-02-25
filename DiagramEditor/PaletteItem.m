//
//  PaletteItem.m
//  DiagramEditor
//
//  Created by Diego Vaquero Melchor on 10/12/15.
//  Copyright © 2015 Diego Vaquero Melchor. All rights reserved.
//

#import "PaletteItem.h"

#define kEllipse @"graphicR:Ellipse"
#define kEdge @"graphicR:Edge"
#define kRectangle @"graphicR:Rectangle"
#define kDiamond @"graphicR:Diamond"
#define kNote @"graphicR:Note"
#define kParallelogram @"graphicR:ShapeCompartmentParallelogram"
#import "Component.h"
#import "ClassAttribute.h"

#define handSize 15

@implementation PaletteItem


@synthesize type, dialog, width, height, shapeType, fillColor, isImage, image, attributes, className, colorString, sourceName, targetName, targetDecoratorName, sourceDecoratorName, edgeStyle, sourcePart, targetPart, sourceClass, targetClass, minOutConnections,maxOutConnections, containerReference, references, parentsClassArray, isDragable;


-(Component *)getComponentForThisPaletteItem{
    Component * comp = [[Component alloc] init];
    
    comp.name = [dialog copy];
    comp.type = [type copy];
    comp.shapeType =  [shapeType copy];
    comp.fillColor = [fillColor copy];
    comp.parentItem = self;
    comp.isDragable = isDragable;
    
    //Copy attributes
    NSData * buffer = [NSKeyedArchiver archivedDataWithRootObject:self.attributes];
    comp.attributes = [NSKeyedUnarchiver unarchiveObjectWithData:buffer];
    
    comp.references = references;
    comp.colorString = [colorString copy];
    
    comp.parentClassArray = parentsClassArray;
    
    comp.containerReference = containerReference;
    comp.className = [className copy];
    
    if(isImage){
        comp.isImage = YES;
        comp.image = image;
    }else{
        comp.isImage = NO;
    }
    
    
    //Ponemos el nombre en el caso de que lo tenga
    for(ClassAttribute * atr in comp.attributes){
        if([atr.name isEqualToString:@"name"]){
            
            //Comprobamos si tiene el default
            if(atr.defaultValue != nil){
                atr.currentValue = atr.defaultValue;
            }else{
                atr.currentValue = nil;
            }
            comp.name = [atr.currentValue copy];
        }
    }
    
    
    return comp;
}


- (void)drawRect:(CGRect)rect {
    
    float lw = 4.0;
    CGRect fixed = CGRectMake(2*lw, 2*lw +5, rect.size.width - 4*lw , rect.size.height - 4*lw);
    
    if([shapeType isEqualToString:kEllipse]){
        
        UIBezierPath * path = [UIBezierPath bezierPathWithOvalInRect:fixed];
        [[UIColor blackColor] setStroke];
       
        [fillColor setFill];
        [path setLineWidth:lw];
        
        
        [path fill];
        [path stroke];
        
    }else if([type isEqualToString:kEdge]){

        UIBezierPath * path = [[UIBezierPath alloc]init];
        [[UIColor blackColor]setStroke];
        [path setLineWidth:lw];
        [path moveToPoint:CGPointMake(2*lw, rect.size.height /2)];
        [path addLineToPoint:CGPointMake(rect.size.width - 2* lw, rect.size.height /2)];
        
        [path stroke];
    }else if([shapeType isEqualToString:kDiamond]){ //Diamond

        
        UIBezierPath * path = [[UIBezierPath alloc] init];
        [[UIColor blackColor] setStroke];
        //[[UIColor whiteColor] setFill];
        [fillColor setFill];
        [path setLineWidth:lw];
        //Use fixed rect
        [path moveToPoint:CGPointMake(fixed.origin.x + fixed.size.width/2, fixed.origin.y + 0) ];
        [path addLineToPoint:CGPointMake(fixed.origin.x + fixed.size.width, fixed.origin.y + fixed.size.height/2)];
        [path addLineToPoint:CGPointMake(fixed.origin.x + fixed.size.width/2, fixed.origin.y + fixed.size.height)];
        [path addLineToPoint:CGPointMake(fixed.origin.x + 0, fixed.origin.y + fixed.size.height/2)];
        [path addLineToPoint:CGPointMake(fixed.origin.x + fixed.size.width/2, fixed.origin.y + 0)];
        [path closePath];
        
        [path fill];
        [path stroke];
    }else if([shapeType isEqualToString:kNote]){ //Note
        
        //fixed = CGRectMake(fixed.origin.x + 2*lw, fixed.origin.y + 2*lw, fixed.size.width, fixed.size.height);
        //fixed = self.frame;
        UIBezierPath * path = [[UIBezierPath alloc] init];
        [[UIColor blackColor]setStroke];
        [fillColor setFill];
        [path setLineWidth:lw];
        
        [path moveToPoint:CGPointMake(fixed.origin.x + 0, fixed.origin.y + 0)];
        [path addLineToPoint:CGPointMake(fixed.origin.x + 0, fixed.origin.y + fixed.size.height)];
        [path addLineToPoint:CGPointMake(fixed.origin.x + fixed.size.width, fixed.origin.y + fixed.size.height)];
        CGPoint corner = CGPointMake(fixed.origin.x + fixed.size.width, fixed.origin.y + fixed.size.height/7.0);
        [path addLineToPoint: corner];
        [path addLineToPoint:CGPointMake(fixed.origin.x + fixed.size.width/7 *6, fixed.origin.y + 0)];
        [path addLineToPoint:CGPointMake(fixed.origin.x + 0, fixed.origin.y + 0)];
        [path closePath];
        
        [path fill];
        [path stroke];
        
        path = [[UIBezierPath alloc] init];
        [path setLineWidth:lw/2];
        [[UIColor whiteColor]setFill];
        [[UIColor blackColor]setStroke];
        [path moveToPoint:corner];
        [path addLineToPoint:CGPointMake(fixed.origin.x + fixed.size.width/7 *6, fixed.origin.y + 0)];
        [path addLineToPoint:CGPointMake(fixed.origin.x + fixed.size.width/7 *6, fixed.origin.y + fixed.size.height/7.0)];
        [path closePath];
        [path fill];
        [path stroke];
        
        
    }else if([shapeType isEqualToString:kParallelogram]){ //Parallelogram
       
        

        UIBezierPath * path = [[UIBezierPath alloc] init];

        [[UIColor blackColor] setStroke];
        [fillColor setFill];
        
        [path setLineWidth:lw];
        
        [path moveToPoint:CGPointMake(fixed.origin.x, fixed.origin.y + fixed.size.height)];
        [path addLineToPoint:CGPointMake(fixed.origin.x + fixed.size.width/4.0*3.0, fixed.origin.y + fixed.size.height)];
        [path addLineToPoint:CGPointMake(fixed.origin.x + fixed.size.width, fixed.origin.y + 0.0)];
        [path addLineToPoint:CGPointMake(fixed.origin.x + fixed.size.width/4, fixed.origin.y + 0)];
        [path closePath];
        [path fill];
        [path stroke];
        

    }else if(isImage){
        [image drawInRect:rect];
        [[UIColor clearColor]setFill];
        UIBezierPath * path = [UIBezierPath bezierPathWithRect:rect];
        [path fill];
    }else if([shapeType isEqualToString:kRectangle]){
        UIBezierPath * path = [[UIBezierPath alloc] init];
        [[UIColor blackColor] setStroke];
        [fillColor setFill];
        
        [path setLineWidth:lw];
        
        [path moveToPoint:CGPointMake(fixed.origin.x , fixed.origin.y )];
        [path addLineToPoint:CGPointMake(fixed.origin.x , fixed.origin.y + fixed.size.height)];
        [path addLineToPoint:CGPointMake(fixed.origin.x + fixed.size.width, fixed.origin.y + fixed.size.height)];
        [path addLineToPoint:CGPointMake(fixed.origin.x + fixed.size.width, fixed.origin.y )];
        [path closePath];
        [path fill];
        [path stroke];
        
        
    }else{
        //Dibujar una cruz o interrogación
    }
    
    //Pintamos el nombre del elemento
    CGRect textRect = CGRectMake(0 , 0, self.frame.size.width, 15);
    NSMutableParagraphStyle* textStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    textStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary* textFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 10], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: textStyle};
    
    [self.className drawInRect: textRect withAttributes: textFontAttributes];
    

    
    
    //Draw hand
    if([self.type isEqualToString:kEdge] ){

    }else{ // !self.isDragable == true
        if(self.isDragable == TRUE){
            CGRect handRect = CGRectMake(self.frame.size.width - handSize , self.frame.size.height - handSize, handSize , handSize);
            UIImage * img = [UIImage imageNamed:@"hand"];
            [img drawInRect:handRect];
        }else{
            CGRect handRect = CGRectMake(self.frame.size.width - handSize , self.frame.size.height - handSize, handSize , handSize);
            UIImage * img = [UIImage imageNamed:@"tap"];
            [img drawInRect:handRect];
        }
    }

}


-(NSString *)description{
    return [NSString stringWithFormat:@"Type: %@\nDialog: %@\nShape type: %@\nClass name: %@\nContainer reference: %@\n", type, dialog, shapeType, className, containerReference];
}

@end
