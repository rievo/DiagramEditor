//
//  Component.m
//  DiagramEditor
//
//  Created by Diego Vaquero Melchor on 5/11/15.
//  Copyright © 2015 Diego Vaquero Melchor. All rights reserved.
//

#import "Component.h"
#import "Connection.h"
#import "Canvas.h"
#import "PaletteItem.h"


#import "EdgeListView.h"
#import "EditorViewController.h"
#import "PaletteItem.h"
#import "NoDraggableClassesView.h"

#import "HiddenInstancesListView.h"

#import "ClassAttribute.h"

#define resizeW 40

#define kNotYet @"NotYet"
#define kDefaultConnection @"DefaultConnection"

#import <AudioToolbox/AudioServices.h>

#define minusY 30

#define kMaxScale 2.0
#define kMinScale 1.0

@implementation Component


@synthesize textLayer, type, shapeType, fillColor, image, isImage, attributes, componentId, colorString, containerReference, className, references, name, parentClassArray, isDragable, canvas, borderStyleString, borderWidth, borderColor, borderColorString;


NSString* const SHOW_INSPECTOR = @"ShowInspector";

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(void)prepare{
    

    
    font = [UIFont fontWithName:@"Helvetica" size:10.0];
    
    [self addTapGestureRecognizer];
    [self addLongPressGestureRecognizer];
    [self addPanGestureRecognizer];
    
    
    dele = [[UIApplication sharedApplication]delegate];
    
    
    self.backgroundColor = [UIColor clearColor];
    //NameLayer
    if(textLayer == nil){
        textLayer = [[CATextLayer alloc] init];
        
        textLayer.foregroundColor = [UIColor blackColor].CGColor;
        CGRect rect = CGRectMake(0 - self.bounds.size.width /2, 0-20, self.frame.size.width * 2,20);
        textLayer.frame = rect;
        textLayer.contentsScale = [UIScreen mainScreen].scale;
        [textLayer setFont:@"Helvetica-Light"];
        [textLayer setFontSize:14];
        textLayer.alignmentMode = kCAAlignmentCenter;
        textLayer.truncationMode = kCATruncationStart;
        textLayer.backgroundColor = [UIColor clearColor].CGColor;
        [self.layer addSublayer:textLayer];
    }else{
        //textLayer.string = name;
        [self updateNameLabel];
    }

    
    
    [self setNeedsDisplay];

    
}

-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        font = [UIFont fontWithName:@"Helvetica" size:10.0];
        
        [self addTapGestureRecognizer];
        [self addLongPressGestureRecognizer];
        [self addPanGestureRecognizer];
        
        
        dele = [[UIApplication sharedApplication]delegate];
        
        
        self.backgroundColor = [UIColor clearColor];
        
        
        //NameLayer
        
        if(textLayer != nil){
            [textLayer removeFromSuperlayer];
        }else{
            textLayer = [[CATextLayer alloc] init];
            
            textLayer.foregroundColor = [UIColor blackColor].CGColor;
            CGRect rect = CGRectMake(0 - self.bounds.size.width /2, 0-20, self.frame.size.width * 2,20);
            textLayer.frame = rect;
            textLayer.contentsScale = [UIScreen mainScreen].scale;
            [textLayer setFont:@"Helvetica-Light"];
            [textLayer setFontSize:14];
            textLayer.alignmentMode = kCAAlignmentCenter;
            textLayer.truncationMode = kCATruncationStart;
            textLayer.backgroundColor = [UIColor clearColor].CGColor;
            [self.layer addSublayer:textLayer];

        }
        
        
        [self setNeedsDisplay];
        

        
        
        //Add UIPinch
        UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scale:)];
        pinchRecognizer.delegate = self;
        [self addGestureRecognizer:pinchRecognizer];
        
    }
    return self;
}

-(void)fitNameLabel{

        [textLayer removeFromSuperlayer];

        textLayer = [[CATextLayer alloc] init];
        
        textLayer.foregroundColor = [UIColor blackColor].CGColor;

        CGRect rect = CGRectMake(0 - self.bounds.size.width /2, 0-20, self.frame.size.width * 2,20);
        textLayer.frame = rect;
        textLayer.contentsScale = [UIScreen mainScreen].scale;
        [textLayer setFont:@"Helvetica-Light"];
        [textLayer setFontSize:14];
        textLayer.alignmentMode = kCAAlignmentCenter;
        textLayer.truncationMode = kCATruncationStart;
        textLayer.backgroundColor = [UIColor clearColor].CGColor;
        [self.layer addSublayer:textLayer];


}


#pragma mark Add Gesture Recognizer

-(void)addTapGestureRecognizer{
    tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapGR.delegate = self;
    [self addGestureRecognizer:tapGR];
    
}


-(void)addLongPressGestureRecognizer{
    longGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longGR.delegate = self;
    [longGR setMinimumPressDuration:0.5];
    [self addGestureRecognizer:longGR];
    
}


-(void)addPanGestureRecognizer{
    panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanComp:)];
    panGR.delegate = self;
    [self addGestureRecognizer:panGR];
}

#pragma mark Handle gestures

-(void)scale:(UIPinchGestureRecognizer *)gestureRecognizer{
    /*if (pinch.state == UIGestureRecognizerStateBegan)
        prevPinchScale = 1.0;
    
    float thisScale = 1 + (pinch.scale-prevPinchScale);
    prevPinchScale = pinch.scale;
    self.transform = CGAffineTransformScale(self.transform, thisScale, thisScale);*/
    if([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        // Reset the last scale, necessary if there are multiple objects with different scales
        lastScale = [gestureRecognizer scale];
    }
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan ||
        [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        
        CGFloat currentScale = [[[gestureRecognizer view].layer valueForKeyPath:@"transform.scale"] floatValue];

        
        CGFloat newScale = 1 -  (lastScale - [gestureRecognizer scale]);
        newScale = MIN(newScale, kMaxScale / currentScale);
        newScale = MAX(newScale, kMinScale / currentScale);
        CGAffineTransform transform = CGAffineTransformScale([[gestureRecognizer view] transform], newScale, newScale);
        [gestureRecognizer view].transform = transform;
        
        lastScale = [gestureRecognizer scale];  // Store the previous scale factor for the next pinch gesture call
    }
}


-(void)handleTap:(UITapGestureRecognizer *)recog{
    
    //Show info popup (edge, node)
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showCompNot"
                                                        object:self
                                                      userInfo:nil];
}


-  (void)handleLongPress:(UILongPressGestureRecognizer*)sender {
    
    CGPoint translatedPoint =  [sender locationInView: dele.can];
    
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
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
            //Los componentes serán self = selected
            //Self = source   selected = target
            
            //TODO:
            NSString * canIMakeConnection = [self checkIntegrityForSource:self
                                                                andTarget:selected];
            
            if(canIMakeConnection == nil){
                Connection * conn = [[Connection alloc] init];
                conn.source = self;
                conn.target = selected;
                
                conn.targetDecorator = connectionToDo.targetDecoratorName;
                conn.sourceDecorator = connectionToDo.sourceDecoratorName;
                
               
                conn.className = connectionToDo.className;
               
                //conn.className = tempClassName;
                
                [conn retrieveAttributesForThisClassName];
                [conn retrieveConnectionGraphicInfo];
                
                [dele.connections addObject:conn];
                
                [[NSNotificationCenter defaultCenter]postNotificationName:@"repaintCanvas" object:self];
                
                [self showAddReferencePopupForConnection:conn];
            }else if([canIMakeConnection isEqualToString:kNotYet]){
                //Tenemos que esperar a que el usuario seleccione el tipo de conexión
            }else if([canIMakeConnection isEqualToString:kDefaultConnection]){
                Connection * conn = [[Connection alloc] init];
                conn.source = self;
                conn.target = targetTemp;
                conn.targetDecorator = NO_DECORATION;
                conn.sourceDecorator = NO_DECORATION;
                
                conn.className = kDefaultConnection;
                
                [dele.connections addObject:conn];
                 [[NSNotificationCenter defaultCenter]postNotificationName:@"repaintCanvas" object:self];
            }else{
                NSLog(@"No se ha podido hacer la conexión");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:canIMakeConnection
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            
        }
        
        dele.fingeredComponent = nil;
    }
    else if (sender.state == UIGestureRecognizerStateBegan){
        AudioServicesPlayAlertSound(1352);
        
        CGPoint oldCenter = sender.view.center;
        CGPoint newCenter = CGPointMake(oldCenter.x, oldCenter.y - minusY);
        
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [sender.view setCenter:newCenter];
                         }
                         completion:^(BOOL finished) {
                             
                             [UIView animateWithDuration:0.2
                                                   delay:0.0
                                                 options:UIViewAnimationOptionCurveEaseOut
                                              animations:^{
                                                  [sender.view setCenter:oldCenter];
                                              }
                                              completion:nil];
                         }];
        
        
        NSLog(@"Empieza el long");
        [dele.can setXArrowStart:oldCenter.x];
        [dele.can setYArrowStart:oldCenter.y];
        
        
    }
    else if(sender.state == UIGestureRecognizerStateChanged){
        
        
        //draw mark on this component
        
        Component * temp;
        
        for(int i = 0; i< [dele.components count]; i++){
            temp = [dele.components objectAtIndex:i];
            
            if(CGRectContainsPoint(temp.frame, translatedPoint)){
                dele.fingeredComponent = temp;
                break;
            }
            dele.fingeredComponent = nil;
        }
        
        
        [dele.can setXArrowEnd:translatedPoint.x];
        [dele.can setYArrowEnd:translatedPoint.y];
        [dele.can setNeedsDisplay];
    }
}


-(void)handlePanComp:(UIPanGestureRecognizer *)sender{
    
    CGPoint translatedPoint =  [sender locationInView: dele.can];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"repaintCanvas" object:self];
    
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
        if(translatedPoint.x > dele.originalCanvasRect.size.width - halfW)
            translatedPoint.x = dele.originalCanvasRect.size.width - halfW;
        
        if(translatedPoint.y < halfh)
            translatedPoint.y = halfh;
        if(translatedPoint.y > dele.originalCanvasRect.size.height - halfh)
            translatedPoint.y = dele.originalCanvasRect.size.height - halfh;
        
        self.center = translatedPoint;
        
    }else if(sender.state == UIGestureRecognizerStateEnded){
        [dele.can setNeedsDisplay];
    }
}


#pragma mark drawRect method
- (void)drawRect:(CGRect)rect {
    
    float lw = 2.0;
    CGRect fixed = CGRectMake(2*lw, 2*lw , rect.size.width - 4*lw , rect.size.height - 4*lw);
    
    UIBezierPath * path = nil;
    
    if([shapeType isEqualToString:@"graphicR:Ellipse"]){
        
        path = [UIBezierPath bezierPathWithOvalInRect:fixed];

        [path setLineWidth:lw];
        
        

        
    }else if([type isEqualToString:@"graphicR:Edge"]){
        
        path = [[UIBezierPath alloc]init];
        [[UIColor blackColor]setStroke];
        [path setLineWidth:lw];
        [path moveToPoint:CGPointMake(2*lw, rect.size.height /2)];
        [path addLineToPoint:CGPointMake(rect.size.width - 2* lw, rect.size.height /2)];
        

    }else if([shapeType isEqualToString:@"graphicR:Diamond"]){ //Diamond
        //fixed.origin.x = fixed.origin.x + 4* lw;
        //fixed.origin.y = fixed.origin.y + 4*lw;
        
        path = [[UIBezierPath alloc] init];
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

    }else if([shapeType isEqualToString:@"graphicR:Note"]){ //Note
        
        //fixed = CGRectMake(fixed.origin.x + 2*lw, fixed.origin.y + 2*lw, fixed.size.width, fixed.size.height);
        //fixed = self.frame;
       path = [[UIBezierPath alloc] init];
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

        
        
    }else if([shapeType isEqualToString:@"graphicR:ShapeCompartmentParallelogram"]){ //Parallelogram
        
        
        
        path = [[UIBezierPath alloc] init];
        
        [[UIColor blackColor] setStroke];
        [fillColor setFill];
        
        [path setLineWidth:lw];
        
        [path moveToPoint:CGPointMake(fixed.origin.x, fixed.origin.y + fixed.size.height)];
        [path addLineToPoint:CGPointMake(fixed.origin.x + fixed.size.width/4.0*3.0, fixed.origin.y + fixed.size.height)];
        [path addLineToPoint:CGPointMake(fixed.origin.x + fixed.size.width, fixed.origin.y + 0.0)];
        [path addLineToPoint:CGPointMake(fixed.origin.x + fixed.size.width/4, fixed.origin.y + 0)];
        [path closePath];

        
    }else if(isImage){
        [image drawInRect:fixed];
    }else if([shapeType isEqualToString:@"graphicR:Rectangle"]){
        path = [[UIBezierPath alloc] init];
        [[UIColor blackColor] setStroke];
        [fillColor setFill];
        
        [path setLineWidth:lw];
        
        [path moveToPoint:CGPointMake(fixed.origin.x , fixed.origin.y )];
        [path addLineToPoint:CGPointMake(fixed.origin.x , fixed.origin.y + fixed.size.height)];
        [path addLineToPoint:CGPointMake(fixed.origin.x + fixed.size.width, fixed.origin.y + fixed.size.height)];
        [path addLineToPoint:CGPointMake(fixed.origin.x + fixed.size.width, fixed.origin.y )];
        [path closePath];

        
        
    }else{
        
    }
    
    [fillColor setFill];
    [borderColor setStroke];
    [path setLineWidth:borderWidth.floatValue];
    
    [self updatePath:path forStyle:borderStyleString];
    
    [path fill];
    [path stroke];
}

-(void)updatePath: (UIBezierPath *)line
         forStyle: (NSString *)style{
    if([style isEqualToString:@"solid"]){
        
    }else if([style isEqualToString:@"dash"]){
        CGFloat dashes[] = {10 , 10};
        [line setLineDash:dashes count:2 phase:0];
    }else if([style isEqualToString:@"dot"]){
        CGFloat dashes[] = {2,5};
        [line setLineDash:dashes count:2 phase:0];
    }else if([style isEqualToString:@"dash_dot"]){
        CGFloat dashes[] = {2,10,10,10};
        [line setLineDash:dashes count:4 phase:0];
    }else { //solid
        
    }
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


-(void)updateNameLabel{
    NSString * text = @"";
    
    for(ClassAttribute * attr in self.attributes){
        if(attr.isLabel == YES){
            text = [text stringByAppendingString:attr.currentValue];
            text = [text stringByAppendingString:@" "];
        }
    }
    
    //textLayer.string = name;
    textLayer.string = text;
    //[self setNeedsDisplay];
    [textLayer setNeedsDisplay];
    [textLayer display];
}


#pragma mark Check integrity
/*
 Cuando el usuario suelte la conexión entre dos elementos: Siempre mirando el GraphicR
 1) Comprobar si del nodo origen puede salir alguna conexión
 2) En caso de que pueda salir conexión, mirar el nodo destino
 2.1)Si no se pueden unir origen y destino, esto es, 0 conexiones posibles
 2.2)Si se pueden unir origen y destino
 2.2.1) Si solo hay una posible conexión en el graphicR, tomarla
 2.2.2) Si hay más de una posible conexión, mostrar un popup para que el usuario elija cuál de ellas
 */


-(NSString *)checkIntegrityForSource: (Component *)source
                           andTarget: (Component *)target
                            withEdge: (PaletteItem *)pi{
    NSString * res = nil;
    
    //Sacamos, de ese tipo, cuántas conexiones pueden salir del source
    //Recorremos las referencias de source, comprobando si el target es del tipo pi.className
    
    NSNumber * minS = nil, *maxS= nil;
    NSNumber * minT= nil, *maxT= nil;
    
    NSString * targetClassName;
    NSString * opposite;
    
    connectionToDo = pi;

    //pi es el edge
    
    BOOL flagSource = false;
    BOOL flagTarget = false;

    
    //Primero buscar la referencia source
    for(Reference * ref in pi.references){
        
        if([ref.name isEqualToString:pi.sourcePart]){ //from
            if([ref.target isEqualToString:source.className]|| [source.parentClassArray containsObject:ref.target]){
                //Compruebo si tiene eopposite
                NSString * opp = ref.opposite;
                if([opp isEqualToString:@"null"]){
                    //Pongo el flag a true
                    flagSource = true;
                }else{
                    //busco ese opp en la clase "target" del json
                    
                    
                    for(Reference * r in source.references){
                        if([r.name isEqualToString:opp]){
                            minS = r.min;
                            maxS = r.max;
                            targetClassName = r.target;
                            opposite = r.opposite;
                            flagSource = true;
                        }
                    }
                    
                }
            }else{
                //No se puede crear la conexión
                //La clase del source no concuerda
                return @"La clase del Source no es la esperada en transition";
            }
        }
    }
    
    
    //Después buscar target
    for(Reference * ref in pi.references){
        
        if([ref.name isEqualToString:pi.targetPart]){ //to
            if([ref.target isEqualToString:target.className] || [target.parentClassArray containsObject:ref.target]){ //Miramos que la clase a la que miro es la que indica, o una de sus padres
                //Compruebo si tiene eopposite
                NSString * opp = ref.opposite;
                if([opp isEqualToString:@"null"]){
                    //Pongo el flag a true
                }else{
                    //busco ese opp en la clase "target" del json
                    //NSString * target = ref.target;
                    
                    for(Reference * r in target.references){
                        if([r.name isEqualToString:opp]){
                            minT = r.min;
                            maxT = r.max;
                            targetClassName = r.target;
                            opposite = r.opposite;
                            flagTarget = true;
                        }
                    }
                    
                }
            }else{
                //No se puede crear la conexión
                //La clase del source no concuerda
                return @"Clase origen no válida";
            }
        }
    }
    
    //final
    
    //Hasta aquí se podría hacer la conexión en función de las referencias que sea
    
    tempClassName = pi.className;
    
    //Comprobamos el grado de entrada y salida
    int inDegree = [dele getInConnectionsForComponent:target ofType:pi.className];
    int outDegree = [dele getOutConnectionsForComponent:source ofType:pi.className];
    
    BOOL sflag = false, tflag = false;
    
    if(minS == nil && maxS == nil){ //No nos importa el grado de salida
        
    }else{
        if([maxS intValue] == -1){//-1 = *
            sflag = true; //
        }else if(outDegree < [maxS intValue]){ //Puedo hacer la conexión por el mínimo
            sflag = true;
        }else{
            return @"Número máximo de conexiones de salida alcanzado";
        }
    }
    
    if(minT == nil && maxT == nil){ //No nos importa el grado de entrada
        
    }else{
        if([maxT intValue] == -1){//-1 = *
            tflag= true; //
        }else if(inDegree < [maxT intValue]){ //Puedo hacer la conexión por el mínimo
            tflag = true;
        }else{
            return @"Número máximo de conexiones de entrada alcanzado";
        }
    }
    
    if(sflag == true && tflag == true){
        //Puedo hacer la conexión
        return nil;
    }

    
    
    return res;
}


-(NSString *)checkIntegrityForSource: (Component *)source
                           andTarget: (Component *)target{
    //BOOL result = false;
    
    
    //Miramos cuántos edges tengo en la paleta
    
    int edges = 0;
    PaletteItem * pi = nil;
    PaletteItem * selectedEdge = nil;
    
    for(int i = 0; i< dele.paletteItems.count; i++){
        pi = [dele.paletteItems objectAtIndex:i];
        
        if([pi.type isEqualToString:@"graphicR:Edge"]){
            edges++;
            selectedEdge = pi; //Solo nos importa pi en el caso de que solo haya uno
        }
    }
    NSLog(@"Tengo %d edges", edges);
    
    //NSString * resultText;
    
    //Pi será el selected edge
    
    if(edges == 0){
        
        //There are no edges, just check references
        for (Reference * ref in self.references) {
            NSString * targetReference = ref.target; //Con qué clase puedo conectar
            
            if([targetReference isEqualToString:target.className] || [target.parentClassArray containsObject:targetReference]){ //Puedo conectar con la clase destino
                //Puedo hacer la conexión
                targetTemp = target;
                return kDefaultConnection;
            }
        }
        
        return @"There are no possible references between those two items";
    
    }else if(edges == 1){
        
        NSString * result = [self checkIntegrityForSource:source andTarget:target withEdge:pi];
        connectionToDo = selectedEdge;
        
        
        return result;
        
        //TODO: Lo recortado en el txt
        
    }else{//More than 1 edge
        sourceTemp = source;
        targetTemp = target;
        NSLog(@"Showing popup");
        EdgeListView * elv = [[[NSBundle mainBundle] loadNibNamed:@"EdgeListView"
                                                            owner:self
                                                          options:nil] objectAtIndex:0];
        elv.targetComponent = target;
        elv.sourceComponent = source;
        
        EditorViewController * evc = dele.evc;
        
        BOOL result = [elv reloadView];
        
        if(result == true){ //Show possible connections
            
            //Do we have just one or more?
            
            if(elv.edges.count == 1){
                connectionToDo = [elv.edges objectAtIndex:0];
                return nil;
            }else{
                [evc.view addSubview:elv];
                [elv setFrame:evc.view.frame];
                [elv setDelegate:self];
                return kNotYet;
            }
            
        }else{ //No possible connections
            return @"There are no possible connections to do between those classes";
        }
       
    }
    return @"";
}



#pragma mark No draggable elements
//This function returns an array with dragabble elements
-(NSMutableArray *)getDraggablePaletteItems{
    NSMutableArray * array = [[NSMutableArray alloc] init];
    
    for(PaletteItem * pi in dele.paletteItems){
        if([pi.type isEqualToString:@"graphicR:Node"]){
            
            if(pi.isDragable == NO){
                //TODO: Añadir una copia de ese objeto, no el objeto en sí
                NSData * buffer = [NSKeyedArchiver archivedDataWithRootObject:pi];
                PaletteItem * copy = [NSKeyedUnarchiver unarchiveObjectWithData:buffer];
                [array addObject:copy];
                //[array addObject:pi];
            }
        }
    }
    
    return array;
}

-(NSMutableArray *)filterArray:(NSMutableArray *)array
                  forClassName:(NSString *)n{
    
    NSMutableArray * result = [[NSMutableArray alloc] init];
    
    for(PaletteItem * pi in array){
        if([pi.className isEqualToString:n]){
            [result addObject:pi];
        }
    }
    
    return result;
}


-(void)showAddReferencePopupForConnection: (Connection *)conn{
    
    NSMutableArray * nodragarray = [self getDraggablePaletteItems];
    
    //Hacemos el filtrado por las clases que nos permitan las referencias de la connexión
    //Saco del array los objetos que no tengan una referencia cuya clase se llame igual
    
    if(nodragarray.count == 0){
        
    }else{
        NSMutableArray * survivors = [[NSMutableArray alloc] init];
        
        //Para cada referencia de conn
        PaletteItem * temp;
        for(Reference * ref in conn.references){
            for(int i = 0; i<nodragarray.count; i++){
                temp = [nodragarray objectAtIndex:i];
                if ([temp.className isEqualToString:ref.target]) {
                    [survivors addObject:temp];
                }
            }
        }
        
        nodragarray = survivors;
        
        
        NoDraggableClassesView * ndv = [[[NSBundle mainBundle] loadNibNamed:@"NoDraggableClassesView"
                                                                      owner:self
                                                                    options:nil] objectAtIndex:0];
        ndv.itemsArray = nodragarray;
        ndv.delegate = self;
        [ndv setFrame:canvas.frame];
        [ndv reloadInfo];
        
        ndv.connection = conn;
        
        CGPoint oldCenter = ndv.center;
        [ndv setCenter:CGPointMake(ndv.center.x, ndv.center.y + ndv.frame.size.height)];
        [canvas addSubview:ndv];
        
        
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [ndv setCenter:oldCenter];
                         }
                         completion:^(BOOL finished) {
                         }];
    }
    
   
}

#pragma mark Description method

-(NSString *)description{
    return [NSString stringWithFormat:@"Name: %@\nType: %@\nClass: %@", name, type, className];
}

#pragma mark EdgeList delegate methods
-(void)selectedEdge:(PaletteItem *)pi{
    NSLog(@"Ha seleccionado %@", [pi description]);
    NSString * result =[self checkIntegrityForSource:sourceTemp
                                           andTarget:targetTemp
                                            withEdge:pi];
    
    
    if(result == nil){
        Connection * conn = [[Connection alloc] init];
        conn.source = sourceTemp;
        conn.target = targetTemp;
        conn.className = tempClassName;
        //TODO: conn.attributes =
        [dele.connections addObject:conn];
        
        conn.lineWidth = pi.lineWidth;
        conn.lineStyle = pi.lineStyle;
        conn.lineColorNameString = pi.lineColorNameString;
        conn.lineColor = pi.lineColor;
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"repaintCanvas" object:self];
        
        
        //TODO: Ofrecer aquí lo de los no draggables
        [self showAddReferencePopupForConnection:conn];
    
        
        
    }else if([result isEqualToString:kNotYet]){
        //Tenemos que esperar a que el usuario seleccione el tipo de conexión
    }else{
        NSLog(@"No se ha podido hacer la conexión");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:result
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
}


#pragma mark NoDraggableView...
-(void)closeDraggableLisView: (UIView *)view
            WithReturnedItem:(PaletteItem *)value
               andConnection:(Connection * )conn
       isRequiredAssignation:(BOOL)required
    isReferencesLimitReached:(BOOL)limitReached
isPossibleToMakeANewAssignation:(BOOL)isPossible{
    
    [view removeFromSuperview];
    
    
    if(limitReached == YES){ //No podré asociar ninguna instancia más. Me salto este paso
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info"
                                                        message:@"The limit of instances has been reached"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }else{
        if(isPossible == true){
            HiddenInstancesListView * hilv = [[[NSBundle mainBundle] loadNibNamed:@"HiddenInstancesListView"
                                                                            owner:self
                                                                          options:nil] objectAtIndex:0];
            hilv.className = value.className;
            [hilv setFrame:canvas.frame];
            [hilv reloadInfo];
            hilv.delegate = self;
            hilv.connection = conn;
            [canvas addSubview:hilv];
        }
    }

}

#pragma mark HiddenInstancesListViewDelegate methods
-(void)closeHILV:(UIView *)view
withSelectedComponent:(Component *)comp
   andConnection:(Connection *)conn{
    //TODO: Añado ese comp a la lista de instancias de la conexión
    
    if(comp != nil){
        NSMutableArray * array = [conn.instancesOfClassesDictionary objectForKey:comp.className];
        
        if(array == nil){
            NSMutableArray * temp = [[NSMutableArray alloc] init];
            [conn.instancesOfClassesDictionary setObject:temp forKey:comp.className];
            array = temp;
        }
        
        [array addObject:comp];
    }
    

    
    [view removeFromSuperview];
}



#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.name forKey:@"name"];
    
    [coder encodeFloat:self.frame.size.height forKey:@"height"];
    [coder encodeFloat:self.frame.size.width forKey:@"width"];
    [coder encodeFloat:self.frame.origin.x forKey:@"xorigin"];
    [coder encodeFloat:self.frame.origin.y forKey:@"yorigin"];
    
    [coder encodeObject:self.type forKey:@"type"];
    [coder encodeObject:self.shapeType forKey:@"shapeType"];
    [coder encodeObject:self.fillColor forKey:@"fillColor"];
    [coder encodeObject:self.colorString forKey:@"colorString"];
    [coder encodeObject:self.image forKey:@"image"];
    [coder encodeBool:self.isImage forKey:@"isImage"];
    [coder encodeBool:self.isDragable forKey:@"isDraggable"];
    [coder encodeObject:componentId forKey:@"componentId"];
    [coder encodeObject:className forKey:@"className"];
    
    [coder encodeObject:self.attributes forKey:@"attributes"];
    [coder encodeObject:self.references forKey:@"references"];
    
    //Node
    [coder encodeObject:self.borderColorString forKey:@"borderColorString"];
    [coder encodeObject:self.borderStyleString forKey:@"borderStyleString"];
    [coder encodeObject:self.borderWidth forKey:@"borderWidth"];
    [coder encodeObject:self.borderColor forKey:@"borderColor"];
    
    //ecore
    [coder encodeObject:self.containerReference forKey:@"containerReference"];
    [coder encodeObject:parentClassArray forKey:@"parentClassArray"];
    
    
    

}

- (id)initWithCoder:(NSCoder *)coder {
    
    float w = [coder decodeFloatForKey:@"width"];
    float h = [coder decodeFloatForKey:@"height"];
    float yo = [coder decodeFloatForKey:@"yorigin"];
    float xo = [coder decodeFloatForKey:@"xorigin"];
    
    self = [super initWithFrame:CGRectMake(xo, yo, w, h)];
    
    if (self) {
        
        self.name = [coder decodeObjectForKey:@"name"];
        self.type = [coder decodeObjectForKey:@"type"];
        self.shapeType = [coder decodeObjectForKey:@"shapeType"];
        self.fillColor = [coder decodeObjectForKey:@"fillColor"];
        self.colorString = [coder decodeObjectForKey:@"colorString"];
        self.image = [coder decodeObjectForKey:@"image"];
        self.isImage = [coder decodeBoolForKey:@"isImage"];
        self.isDragable = [coder decodeBoolForKey:@"isDraggable"];
        self.componentId  = [coder decodeObjectForKey:@"componentId"];
        self.className = [coder decodeObjectForKey:@"className"];
        
        
        self.attributes = [coder decodeObjectForKey:@"attributes"];
        self.references = [coder decodeObjectForKey:@"references"];
        
        self.borderColorString = [coder decodeObjectForKey:@"borderColorString"];
        self.borderStyleString = [coder decodeObjectForKey:@"borderStyleString"];
        self.borderWidth  = [coder decodeObjectForKey:@"borderWidth"];
        self.borderColor = [coder decodeObjectForKey:@"borderColor"];
        
        self.containerReference  = [coder decodeObjectForKey:@"containerReference"];
        self.parentClassArray  = [coder decodeObjectForKey:@"parentClassArray"];

    }
    return self;
}


@end
