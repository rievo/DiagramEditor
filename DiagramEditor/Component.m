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

#define resizeW 40

#define kNotYet @"NotYet"

#import <AudioToolbox/AudioServices.h>

#define minusY 30

@implementation Component


@synthesize textLayer, type, shapeType, fillColor, image, isImage, attributes, parent, sons, componentId, colorString, containerReference, className, references, name, parentClassArray;


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
        
        font = [UIFont fontWithName:@"Helvetica" size:10.0];
        
        [self addTapGestureRecognizer];
        [self addLongPressGestureRecognizer];
        [self addPanGestureRecognizer];
        
        
        dele = [[UIApplication sharedApplication]delegate];
        
        
        
        
        self.backgroundColor = [UIColor clearColor];
        
        /*
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
         [self.layer addSublayer:backgroundLayer];*/
        
        
        
        //NameLayer
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
        
        [self setNeedsDisplay];
        
        
        /*
         //Add resizeView
         resizeView  = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.width, self.bounds.size.height, resizeW, resizeW)];
         [resizeView setUserInteractionEnabled:YES];
         resizeView.backgroundColor = [UIColor redColor];
         [self addSubview:resizeView];
         
         resizeGr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleResize:)];
         [resizeView addGestureRecognizer:resizeGr];*/
        
        
        parent = nil;
        sons = [[NSMutableArray alloc] init];
        
        
        //Add UIPinch
        UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scale:)];
        pinchRecognizer.delegate = self;
        [self addGestureRecognizer:pinchRecognizer];
        
    }
    return self;
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

-(void)scale:(UIPinchGestureRecognizer *)pinch{
    if (pinch.state == UIGestureRecognizerStateBegan)
        prevPinchScale = 1.0;
    
    float thisScale = 1 + (pinch.scale-prevPinchScale);
    prevPinchScale = pinch.scale;
    self.transform = CGAffineTransformScale(self.transform, thisScale, thisScale);
}

-(void)handleResize:(UIPanGestureRecognizer *)recog{
    
    CGPoint newPoint = [recog locationInView:self];
    
    if(recog.state == UIGestureRecognizerStateBegan){
        NSLog(@"started");
        
    }else if(recog.state == UIGestureRecognizerStateChanged){
        NSLog(@"Agrandaaando");
        //recog.view.transform = CGAffineTransformScale(recog.view.transform, recog.scale, recog.scale);
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, newPoint.x - resizeW/2, newPoint.y-resizeW/2)];
        [self setNeedsDisplay];
    }else if(recog.state == UIGestureRecognizerStateEnded){
        NSLog(@"Ended");
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
                //TODO: Asignar conn.className
                conn.className = tempClassName;
                
                [dele.connections addObject:conn];
                
                [[NSNotificationCenter defaultCenter]postNotificationName:@"repaintCanvas" object:self];
            }else if([canIMakeConnection isEqualToString:kNotYet]){
                //Tenemos que esperar a que el usuario seleccione el tipo de conexión
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
    
    if([shapeType isEqualToString:@"graphicR:Ellipse"]){
        
        UIBezierPath * path = [UIBezierPath bezierPathWithOvalInRect:fixed];
        [[UIColor blackColor] setStroke];
        
        [fillColor setFill];
        [path setLineWidth:lw];
        
        
        [path fill];
        [path stroke];
        
    }else if([type isEqualToString:@"graphicR:Edge"]){
        
        UIBezierPath * path = [[UIBezierPath alloc]init];
        [[UIColor blackColor]setStroke];
        [path setLineWidth:lw];
        [path moveToPoint:CGPointMake(2*lw, rect.size.height /2)];
        [path addLineToPoint:CGPointMake(rect.size.width - 2* lw, rect.size.height /2)];
        
        [path stroke];
    }else if([shapeType isEqualToString:@"graphicR:Diamond"]){ //Diamond
        //fixed.origin.x = fixed.origin.x + 4* lw;
        //fixed.origin.y = fixed.origin.y + 4*lw;
        
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
    }else if([shapeType isEqualToString:@"graphicR:Note"]){ //Note
        
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
        
        
    }else if([shapeType isEqualToString:@"graphicR:ShapeCompartmentParallelogram"]){ //Parallelogram
        
        
        
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
    }else if([shapeType isEqualToString:@"graphicR:Rectangle"]){
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
    textLayer.string = name;
    [self setNeedsDisplay];
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
                return @"Clase origen no válida";
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
    
    if(edges == 0){
        //No se podrá hacer ninguna conexión
        NSLog(@"No hay edges");
    }else if(edges == 1){
        //Se intentará tomar ese edge como defecto y luego se comprobará si puedo usarlo o no
        //selectedEdge contendrá ese edge
        //pi.nameClass tiene el nombre de la clase de ese Edge (e.g. Transition)
        
        
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
                    return @"Clase origen no válida";
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
        
        
        
        
    }else{//More than 1 edge
        sourceTemp = source;
        targetTemp = target;
        NSLog(@"Showing popup");
        EdgeListView * elv = [[[NSBundle mainBundle] loadNibNamed:@"EdgeListView"
                                                            owner:self
                                                          options:nil] objectAtIndex:0];
        EditorViewController * evc = dele.evc;
        [evc.view addSubview:elv];
        [elv setFrame:evc.view.frame];
        [elv setDelegate:self];
        return kNotYet;
    }
    return @"";
}



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
        [dele.connections addObject:conn];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"repaintCanvas" object:self];
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


@end
