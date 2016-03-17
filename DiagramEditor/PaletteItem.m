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


@synthesize type, dialog, width, height, shapeType, fillColor, isImage, image, attributes, className, colorString, sourceName, targetName, targetDecoratorName, sourceDecoratorName, edgeStyle, sourcePart, targetPart, sourceClass, targetClass, minOutConnections,maxOutConnections, containerReference, references, parentsClassArray, isDragable, lineColor, lineColorNameString, lineStyle, lineWidth, borderStyleString, borderWidth, borderColorString, borderColor, labelsAttributesArray;



#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {

    [coder encodeObject:self.type forKey:@"type"];
    [coder encodeObject:self.dialog forKey:@"dialog"];
    [coder encodeObject:self.width forKey:@"width"];
    [coder encodeObject:self.height forKey:@"height"];
    [coder encodeObject:self.shapeType forKey:@"shapeType"];
    [coder encodeObject:self.fillColor forKey:@"fillColor"];
    [coder encodeObject:self.colorString forKey:@"colorString"];
    [coder encodeObject:self.image forKey:@"image"];
    [coder encodeBool:self.isImage forKey:@"isImage"];
    [coder encodeBool:self.isDragable forKey:@"isDragable"];
    [coder encodeObject:self.className forKey:@"className"];
    [coder encodeObject:self.attributes forKey:@"attributes"];
    [coder encodeObject:self.references forKey:@"references"];
    [coder encodeObject:self.edgeStyle forKey:@"edgeStyle"];
    [coder encodeObject:self.sourceDecoratorName forKey:@"sourceDecoratorName"];
    [coder encodeObject:self.targetDecoratorName forKey:@"targetDecoratorName"];
    [coder encodeObject:self.sourceName forKey:@"sourceName"];
    [coder encodeObject:self.targetName forKey:@"targetName"];
    [coder encodeObject:self.sourcePart forKey:@"sourcePart"];
    [coder encodeObject:self.targetPart forKey:@"targetPart"];
    [coder encodeObject:self.sourceClass forKey:@"sourceClass"];
    [coder encodeObject:self.targetClass forKey:@"targetClass"];
    [coder encodeObject:self.minOutConnections forKey:@"minOutConnections"];
    [coder encodeObject:self.maxOutConnections forKey:@"maxOutConnections"];
    [coder encodeObject:self.containerReference forKey:@"containerReference"];
    [coder encodeObject:self.parentsClassArray forKey:@"parentsClassArray"];
    [coder encodeObject:self.labelsAttributesArray forKey:@"labelsAttributesArray"];
    
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        
        self.type = [coder decodeObjectForKey:@"type"];
        self.dialog = [coder decodeObjectForKey:@"dialog"];
        self.width = [coder decodeObjectForKey:@"width"];
        self.height = [coder decodeObjectForKey:@"height"];
        self.shapeType = [coder decodeObjectForKey:@"shapeType"];
        self.fillColor = [coder decodeObjectForKey:@"fillColor"];
        self.colorString = [coder decodeObjectForKey:@"colorString"];
        self.image = [coder decodeObjectForKey:@"image"];
        self.isImage = [coder decodeBoolForKey:@"isImage"];
        self.isDragable = [coder decodeBoolForKey:@"isDragable"];

        self.className = [coder decodeObjectForKey:@"className"];
        self.attributes = [coder decodeObjectForKey:@"attributes"];
        self.references = [coder decodeObjectForKey:@"references"];
        self.edgeStyle = [coder decodeObjectForKey:@"edgeStyle"];
        self.sourceDecoratorName = [coder decodeObjectForKey:@"sourceDecoratorName"];
        self.targetDecoratorName = [coder decodeObjectForKey:@"targetDecoratorName"];
        self.sourceName = [coder decodeObjectForKey:@"sourceName"];
        self.targetName = [coder decodeObjectForKey:@"targetName"];
        self.sourcePart = [coder decodeObjectForKey:@"sourcePart"];
        self.targetPart = [coder decodeObjectForKey:@"targetPart"];
        self.sourceClass = [coder decodeObjectForKey:@"sourceClass"];
        self.targetClass= [coder decodeObjectForKey:@"targetClass"];
        self.minOutConnections = [coder decodeObjectForKey:@"minOutConnections"];
        self.maxOutConnections = [coder decodeObjectForKey:@"maxOutConnections"];
        self.containerReference = [coder decodeObjectForKey:@"containerReference"];
        self.parentsClassArray= [coder decodeObjectForKey:@"parentsClassArray"];
        self.labelsAttributesArray = [coder decodeObjectForKey:@"labelsAttributesArray"];

    }
    return self;
}


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
    
    
    comp.borderWidth = borderWidth;
    comp.borderStyleString = borderStyleString;
    comp.borderColorString = borderColorString;
    comp.borderColor = borderColor;

    
    if(isImage){
        comp.isImage = YES;
        comp.image = image;
    }else{
        comp.isImage = NO;
    }
    
    
    //Ponemos el nombre en el caso de que lo tenga
    for(ClassAttribute * atr in comp.attributes){

            if(atr.defaultValue != nil){
                atr.currentValue = atr.defaultValue;
            }else{
                atr.currentValue = @"";
            }
            comp.name = [atr.currentValue copy];

    }
    
    
    return comp;
}

-(void)updatePath: (UIBezierPath *)line
         forStyle: (NSString *)style{
    if([style isEqualToString:SOLID]){
        
    }else if([style isEqualToString:DASH]){
        CGFloat dashes[] = {10 , 10};
        [line setLineDash:dashes count:2 phase:0];
    }else if([style isEqualToString:DOT]){
        CGFloat dashes[] = {2,5};
        [line setLineDash:dashes count:2 phase:0];
    }else if([style isEqualToString:DASH_DOT]){
        CGFloat dashes[] = {2,10,10,10};
        [line setLineDash:dashes count:4 phase:0];
    }else { //solid
        
    }
}


- (void)drawRect:(CGRect)rect {
    
    float lw = 4.0;
    CGRect fixed = CGRectMake(2*lw, 2*lw +5, rect.size.width - 4*lw , rect.size.height - 4*lw);
    
    UIBezierPath * path = nil;
    
    if([shapeType isEqualToString:kEllipse]){
        
       path = [UIBezierPath bezierPathWithOvalInRect:fixed];
        
    }else if([type isEqualToString:kEdge]){

        path = [[UIBezierPath alloc]init];

        [path moveToPoint:CGPointMake(2*lw, rect.size.height /2)];
        [path addLineToPoint:CGPointMake(rect.size.width - 2* lw, rect.size.height /2)];
        

    }else if([shapeType isEqualToString:kDiamond]){ //Diamond

        
        path = [[UIBezierPath alloc] init];

        [path moveToPoint:CGPointMake(fixed.origin.x + fixed.size.width/2, fixed.origin.y + 0) ];
        [path addLineToPoint:CGPointMake(fixed.origin.x + fixed.size.width, fixed.origin.y + fixed.size.height/2)];
        [path addLineToPoint:CGPointMake(fixed.origin.x + fixed.size.width/2, fixed.origin.y + fixed.size.height)];
        [path addLineToPoint:CGPointMake(fixed.origin.x + 0, fixed.origin.y + fixed.size.height/2)];
        [path addLineToPoint:CGPointMake(fixed.origin.x + fixed.size.width/2, fixed.origin.y + 0)];
        [path closePath];

    }else if([shapeType isEqualToString:kNote]){ //Note
        

        path = [[UIBezierPath alloc] init];

        
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

        
        
    }else if([shapeType isEqualToString:kParallelogram]){ //Parallelogram
       
        

        path = [[UIBezierPath alloc] init];
        
        [path moveToPoint:CGPointMake(fixed.origin.x, fixed.origin.y + fixed.size.height)];
        [path addLineToPoint:CGPointMake(fixed.origin.x + fixed.size.width/4.0*3.0, fixed.origin.y + fixed.size.height)];
        [path addLineToPoint:CGPointMake(fixed.origin.x + fixed.size.width, fixed.origin.y + 0.0)];
        [path addLineToPoint:CGPointMake(fixed.origin.x + fixed.size.width/4, fixed.origin.y + 0)];
        [path closePath];

        

    }else if(isImage){
        [image drawInRect:fixed];
        /*[[UIColor redColor]setFill];
        UIBezierPath * path = [UIBezierPath bezierPathWithRect:fixed];
        [path fill];*/
    }else if([shapeType isEqualToString:kRectangle]){
        path = [[UIBezierPath alloc] init];

        
        [path moveToPoint:CGPointMake(fixed.origin.x , fixed.origin.y )];
        [path addLineToPoint:CGPointMake(fixed.origin.x , fixed.origin.y + fixed.size.height)];
        [path addLineToPoint:CGPointMake(fixed.origin.x + fixed.size.width, fixed.origin.y + fixed.size.height)];
        [path addLineToPoint:CGPointMake(fixed.origin.x + fixed.size.width, fixed.origin.y )];
        [path closePath];

        
        
    }else{
        //Dibujar una cruz o interrogación
    }
    
    
    [fillColor setFill];
    [borderColor setStroke];
    [path setLineWidth:borderWidth.floatValue];
    
    [self updatePath:path  forStyle: borderStyleString];

    
    if([type isEqualToString:kEdge]){
        [path setLineWidth:lineWidth.floatValue];
        [lineColor setStroke];
        [lineColor setFill];
        [self updatePath:path forStyle:lineStyle];
    }
    [path stroke];
        [path fill];
    
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
