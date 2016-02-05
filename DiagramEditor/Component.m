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

#define resizeW 40

#define kNotYet @"NotYet"

#import <AudioToolbox/AudioServices.h>

#define minusY 30

@implementation Component


@synthesize textLayer, type, shapeType, fillColor, image, isImage, attributes, parent, sons, componentId, colorString, containerReference, className, references, name;


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
            
            
            NSString * canIMakeConnection = [self checkIntegrityForSource:self
                                                                andTarget:selected];
            
            if(canIMakeConnection == nil){
                Connection * conn = [[Connection alloc] init];
                conn.source = self;
                conn.target = selected;
                
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
/*
 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info"
 message:@"There is no available Edges"
 delegate:self
 cancelButtonTitle:@"OK"
 otherButtonTitles:nil];
 [alert show];*/

-(NSString *)checkIntegrityForSource: (Component *)source
                           andTarget: (Component *)target
                            withEdge: (PaletteItem *)pi{
    NSString * res = nil;
    
    //Sacamos, de ese tipo, cuántas conexiones pueden salir del source
    //Recorremos las referencias de source, comprobando si el target es del tipo pi.className
    NSNumber * min, *max;
    
    NSString * targetClassName;
    NSString * opposite;
    //pi es el edge
    for(Reference * ref in source.references){
        if([ref.target isEqualToString:pi.className]){
            min = ref.min;
            max = ref.max;
            targetClassName = ref.target;
            opposite = ref.opposite;
        }
    }
    //Hemos calculado cuántas referencias pueden salir del nodo source
    
    
    //Compruebo si el nodo target es de la clase necesaria
    
    
    //Tengo que mirar en pi, la referencia "opposite" y mirar a qué clase apunta (su target)
    NSString * destinyclass;
    for(Reference * ref in pi.references){
        if([ref.name isEqualToString:opposite]){
            destinyclass = ref.target;
        }
    }
    
    
    NSLog(@"Tenemos qu eel nodo %@\n puede tener de la clase %@ entre %@ y %@ conexiones", source, pi.className, [min description], [max description]);
    
    
    if(max.intValue == 0){ //De este nodo no puede salir nada
        return @"De este nodo no pueden salir referencias";
    }else{
        //Sacamos cuántas conexiones tiene ahora
        
        int currentConnections = [dele getOutConnectionsForComponent:source];
        NSLog(@"El nodo %@ tiene actualmente %d conexiones", source, currentConnections);
        
        if([destinyclass isEqualToString:target.className]){
            //El destino de la conexión es de la clase requerida, sigo comprobando
            
            if(max.intValue == -1){
                //Puede haber cualquier número de conexiones salientes, return true
                return nil;
            }else{
                if(currentConnections < max.intValue){
                    return nil;
                }else{
                    return @"El número de conexiones es demasiado alto. \nBorre alguna";
                }
            }
        }else{
            //El nodo destino no tiene la clase adecuada
            return @"El nodo destino no tiene la clase adecuada";
        }
        
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
        
        //Sacamos, de ese tipo, cuántas conexiones pueden salir del source
        //Recorremos las referencias de source, comprobando si el target es del tipo pi.className
        NSNumber * min, *max;
        
        NSString * targetClassName;
        NSString * opposite;
        //pi es el edge
        for(Reference * ref in source.references){
            if([ref.target isEqualToString:pi.className]){
                min = ref.min;
                max = ref.max;
                targetClassName = ref.target;
                opposite = ref.opposite;
            }
        }
        //Hemos calculado cuántas referencias pueden salir del nodo source
        
        
        //Compruebo si el nodo target es de la clase necesaria
        
        
        //Tengo que mirar en pi, la referencia "opposite" y mirar a qué clase apunta (su target)
        NSString * destinyclass;
        for(Reference * ref in pi.references){
            if([ref.name isEqualToString:opposite]){
                destinyclass = ref.target;
            }
        }
        
        
        NSLog(@"Tenemos qu eel nodo %@\n puede tener de la clase %@ entre %@ y %@ conexiones", source, pi.className, [min description], [max description]);
        
        
        if(max.intValue == 0){ //De este nodo no puede salir nada
            return @"De este nodo no pueden salir referencias";
        }else{
            //Sacamos cuántas conexiones tiene ahora
            
            int currentConnections = [dele getOutConnectionsForComponent:source];
            NSLog(@"El nodo %@ tiene actualmente %d conexiones", source, currentConnections);
            
            if([destinyclass isEqualToString:target.className]){
                //El destino de la conexión es de la clase requerida, sigo comprobando
                
                if(max.intValue == -1){
                    //Puede haber cualquier número de conexiones salientes, return true
                    return nil;
                }else{
                    if(currentConnections < max.intValue){
                        return nil;
                    }else{
                        return @"El número de conexiones es demasiado alto. \nBorre alguna";
                    }
                }
            }else{
                //El nodo destino no tiene la clase adecuada
                return @"El nodo destino no tiene la clase adecuada";
            }
            
        }
        
        
        
        
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


//[0]: min
//[1]: max

/*
 -(NSArray *)getMinAndMaxForClass: (NSString *)class
 andEcoreClass: (NSString *)ecls
 andProperty: (NSString *)pro{
 NSMutableArray * arr = [[NSMutableArray alloc]init];
 
 PaletteItem * pi = nil;
 for(int i = 0; i< dele.paletteItems.count; i++){
 pi = [dele.paletteItems objectAtIndex:i];
 
 if([pi.className isEqualToString:class]){
 //Pi es la clase del ecore que quiero mirar
 NSNumber * min = pi.minOutConnections;
 NSNumber * max = pi.maxOutConnections;
 
 [arr addObject:min];
 [arr addObject:max];
 }
 }
 
 return arr;
 }
 */
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
