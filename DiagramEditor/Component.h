//
//  Component.h
//  DiagramEditor
//
//  Created by Diego Vaquero Melchor on 5/11/15.
//  Copyright © 2015 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Canvas.h"
@class Component;

@interface Component : UIView <UIGestureRecognizerDelegate>{
    
    UITapGestureRecognizer * tapGR;
    UILongPressGestureRecognizer * longGR;
    UIPanGestureRecognizer * panGR;
    
    
    UIFont * font;
    AppDelegate * dele;

    UIPanGestureRecognizer * resizeGr;

    CAShapeLayer * backgroundLayer;
    
    UIView * resizeView;
    
    float prevPinchScale;
    
    Component * sourceTemp;
    Component * targetTemp;
}


//@property NSString * name;
@property CATextLayer * textLayer;
@property NSString * type;
@property NSString * shapeType;
@property UIColor * fillColor;
@property NSString * colorString;
@property UIImage * image;
@property BOOL isImage;
@property NSString * componentId;
@property NSString * className;

@property NSMutableArray * attributes;
@property NSMutableArray * references;

@property Component * parent;
@property NSMutableArray * sons;


@property NSString * name;



//Los cuatro siguientes son para buscar en el ecore

@property NSString * containerReference; //nombre de la referencia que lo contiene en la clase root. Sin parsear. Ejemplo: DFAAutomaton.ecore#//Automaton/alphabet


-(CGPoint)getTopAnchorPoint;
-(CGPoint)getBotAnchorPoint;
-(CGPoint)getLeftAnchorPoint;
-(CGPoint)getRightAnchorPoint;

-(void)updateNameLabel;

@end
