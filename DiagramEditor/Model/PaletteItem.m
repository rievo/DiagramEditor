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
#import "Canvas.h"
#import "AppDelegate.h"
#import "Reference.h"
#import "ColorPalette.h"

#import "Constants.h"

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
    
    [coder encodeObject:self.lineColorNameString forKey:@"lineColorNameString"];
    [coder encodeObject:self.lineStyle forKey:@"lineStyle"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
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
        
        self.lineColorNameString = [coder decodeObjectForKey:@"lineColorNameString"];
        self.lineStyle = [coder decodeObjectForKey:@"lineStyle"];
        self.lineColor = [ColorPalette colorForString:self.lineColorNameString];

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
    
    
    //Copy linkPalettes
    NSData * lidata = [NSKeyedArchiver archivedDataWithRootObject:self.linkPaletteDic];
    comp.linkPaletteDic = [NSKeyedUnarchiver unarchiveObjectWithData:lidata];
    
    comp.references = references;
    comp.colorString = [colorString copy];
    
    comp.parentClassArray = parentsClassArray;
    
    comp.containerReference = containerReference;
    comp.className = [className copy];
    
    
    comp.borderWidth = borderWidth;
    comp.borderStyleString = borderStyleString;
    comp.borderColorString = borderColorString;
    comp.borderColor = borderColor;
    
    comp.labelPosition = _labelPosition;

    comp.isExpandable = _isExpandable;
    NSData * copyExpandableItems = [NSKeyedArchiver archivedDataWithRootObject:_expandableItems];
    comp.expandableItems = [NSKeyedUnarchiver unarchiveObjectWithData:copyExpandableItems];

    
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
    
    if(width != nil && height != nil){ //remake fixed

        float scale = MIN(fixed.size.width / width.floatValue, fixed.size.height / height.floatValue);
        
        
        float newW = width.floatValue * scale;
        float newH = height.floatValue * scale;
        
        float xo = rect.size.width/2 - newW/2;
        float yo = rect.size.height/2 - newH/2;
        
        
        fixed = CGRectMake(xo , yo, newW, newH);
        
    }
    
    //Draw border
    UIBezierPath * border = [[UIBezierPath alloc ] init];
    [border moveToPoint:rect.origin];
    [border addLineToPoint:CGPointMake(rect.origin.x + rect.size.width, rect.origin.y)];
    [border addLineToPoint:CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height)];
    [border addLineToPoint:CGPointMake(rect.origin.x, rect.origin.y + rect.size.height)];
    [border closePath];
    [border setLineWidth:0.2];
    
    [[UIColor blackColor]setStroke];
    [border stroke];
    
    
    //Draw element
    
    UIBezierPath * path = nil;
    
    if([shapeType isEqualToString:kEllipse]){
        
       path = [UIBezierPath bezierPathWithOvalInRect:fixed];
        
    }else if([type isEqualToString:kEdge]){

        [lineColor setStroke];
        path = [[UIBezierPath alloc]init];

        [path moveToPoint:CGPointMake(2*lw+5, rect.size.height /2)];
        [path addLineToPoint:CGPointMake(rect.size.width - 2* lw -5, rect.size.height /2)];
        

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
        if(lineWidth.floatValue <= 0)
            [path setLineWidth:2.0];
        else
            [path setLineWidth:lineWidth.floatValue];
        [lineColor setStroke];
        [lineColor setFill];
        [self updatePath:path forStyle:lineStyle];
        
    }
    [path stroke];
    [path fill];
    
    if([type isEqualToString:kEdge]){
        //Draw decorators
        
        //Source (left)
        UIBezierPath * pathSource = nil;
        
        if([self.sourceDecoratorName isEqualToString:NO_DECORATION]){
            pathSource = [Canvas getNoDecoratorPath];
        }else if([self.sourceDecoratorName isEqualToString:INPUT_ARROW]){
            
            pathSource = [Canvas getInputArrowPath];
            
        }else if([self.sourceDecoratorName isEqualToString:DIAMOND]){
            pathSource = [Canvas getDiamondPath];
        }else if([self.sourceDecoratorName isEqualToString:FILL_DIAMOND]){
            pathSource = [Canvas getDiamondPath];
            
        }else if([self.sourceDecoratorName isEqualToString:INPUT_CLOSED_ARROW]){
            pathSource = [Canvas getInputClosedArrowPath];
            
        }else if([self.sourceDecoratorName isEqualToString:INPUT_FILL_CLOSED_ARROW]){
            pathSource = [Canvas getInputFillClosedArrowPath];
            
        }else if([self.sourceDecoratorName isEqualToString:OUTPUT_ARROW]){
            pathSource = [Canvas getOutputArrowPath];
            
        }else if([self.sourceDecoratorName isEqualToString:OUTPUT_CLOSED_ARROW]){
            pathSource = [Canvas getOutputClosedArrowPath];
        }else if([self.sourceDecoratorName isEqualToString:OUTPUT_FILL_CLOSED_ARROW]){
            pathSource = [Canvas getOutputClosedArrowPath];
        }else{ //No decorator
            pathSource = [Canvas getNoDecoratorPath];
        }
        
        CGAffineTransform transformSource = CGAffineTransformIdentity;
        float angle = M_PI;
        transformSource = CGAffineTransformConcat(transformSource, CGAffineTransformMakeRotation(angle));
        transformSource = CGAffineTransformConcat(transformSource,
                                                  CGAffineTransformMakeTranslation(fixed.origin.x,fixed.size.height/2 + fixed.origin.y -decoratorSize/2));

        [pathSource applyTransform:transformSource];
        [pathSource stroke];
        if([self.sourceDecoratorName isEqualToString:FILL_DIAMOND] ||
           [self.sourceDecoratorName isEqualToString:INPUT_FILL_CLOSED_ARROW] ||
           [self.sourceDecoratorName isEqualToString:OUTPUT_FILL_CLOSED_ARROW]){
            [pathSource fill];
        }
        
        
        //Target
        UIBezierPath * pathTarget= nil;
        
        if([self.targetDecoratorName isEqualToString:NO_DECORATION]){
            pathTarget = [Canvas getNoDecoratorPath];
        }else if([self.targetDecoratorName isEqualToString:INPUT_ARROW]){
            
            pathTarget = [Canvas getInputArrowPath];
            
        }else if([self.targetDecoratorName isEqualToString:DIAMOND]){
            pathTarget = [Canvas getDiamondPath];
        }else if([self.targetDecoratorName isEqualToString:FILL_DIAMOND]){
            pathTarget = [Canvas getDiamondPath];
            
        }else if([self.targetDecoratorName isEqualToString:INPUT_CLOSED_ARROW]){
            pathTarget = [Canvas getInputClosedArrowPath];
            
        }else if([self.targetDecoratorName isEqualToString:INPUT_FILL_CLOSED_ARROW]){
            pathTarget = [Canvas getInputFillClosedArrowPath];
            
        }else if([self.targetDecoratorName isEqualToString:OUTPUT_ARROW]){
            pathTarget = [Canvas getOutputArrowPath];
            
        }else if([self.targetDecoratorName isEqualToString:OUTPUT_CLOSED_ARROW]){
            pathTarget = [Canvas getOutputClosedArrowPath];
        }else if([self.targetDecoratorName isEqualToString:OUTPUT_FILL_CLOSED_ARROW]){
            pathTarget = [Canvas getOutputClosedArrowPath];
        }else{ //No decorator
            pathTarget = [Canvas getNoDecoratorPath];
        }
        
        CGAffineTransform transformTarget = CGAffineTransformIdentity;
        transformTarget = CGAffineTransformConcat(transformTarget,
                                                  CGAffineTransformMakeTranslation(fixed.origin.x + fixed.size.width ,
                                                                                   fixed.size.height/2 + fixed.origin.y -decoratorSize/2));
        [pathTarget applyTransform:transformTarget];
        [pathTarget stroke];
        
        if([self.targetDecoratorName isEqualToString:FILL_DIAMOND] ||
           [self.targetDecoratorName isEqualToString:INPUT_FILL_CLOSED_ARROW] ||
           [self.targetDecoratorName isEqualToString:OUTPUT_FILL_CLOSED_ARROW]){
            [pathTarget fill];
        }

        

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



-(NSString *)getSourceClassName{
    NSString * result = @"";
    
    AppDelegate * dele = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    PaletteItem * temp = nil;
    
    for(temp in dele.paletteItems){
        if([temp.className isEqualToString:sourceName] || [temp.parentsClassArray containsObject:sourceName]){
            //For each reference
            for(Reference * ref in temp.references){
                if([ref.name isEqualToString:sourcePart]){
                    result = ref.target;
                }
            }
        }
    }
    
    
    return result;
}

-(NSString *)getTargetClassName{
    NSString * result = @"";
    
    AppDelegate * dele = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    PaletteItem * temp = nil;
    
    for(temp in dele.paletteItems){
        if([temp.className isEqualToString:targetName] || [temp.parentsClassArray containsObject:targetName]){
            //For each reference
            for(Reference * ref in temp.references){
                if([ref.name isEqualToString:targetPart]){
                    result = ref.target;
                }
            }
        }
    }
    
    
    return result;
}


-(Reference *)getReferenceForName:(NSString *)name{
    Reference * temp = nil;
    
    for(Reference * ref in references){
        if([ref.name isEqualToString:name])
            return ref;
    }
    
    return  temp;
}

-(BOOL)sourceMatchesWithComponent:(Component *)source{ //cname -> Clase del nodo source
    
    NSString * sourceRefName = sourcePart;
    Reference * ref = [self getReferenceForName:sourceRefName];
    
    if(ref == nil){
        return NO;
    }else{
        NSString * trgClass = ref.target;
        
        NSString * class = source.className;
        
        if([class isEqualToString:trgClass] || [source.parentClassArray containsObject:trgClass]){
            return YES;
        }else{
            return NO;
        }
    }

    /*if([sourceName isEqualToString:cname] || [parentsClassArray containsObject:sourceName]){
        return  YES;
    }else{
        return NO;
    }*/
    return NO;
}

-(BOOL)targetMatchesWithComponent:(Component *)targetNode{
    /*if([targetName isEqualToString:cname] || [parentsClassArray containsObject:targetName]){
        return  YES;
    }else{
        return NO;
    }*/
    
    NSString * targetRefName = targetPart;
    Reference * ref = [self getReferenceForName:targetRefName];
    
    if(ref == nil){
        return NO;
    }else{
        NSString * trgClass = ref.target;
        
        NSString * class = targetNode.className;
        
        if([class isEqualToString:trgClass] || [targetNode.parentClassArray containsObject:trgClass]){
            return YES;
        }else{
            return NO;
        }
    }
    
    
    
    return NO;
}


-(BOOL)isPaletteItemOfClass:(NSString *)cname{
    if([className isEqualToString:cname] || [parentsClassArray containsObject:cname]){
        return  YES;
    }else{
        return NO;
    }
}

@end
