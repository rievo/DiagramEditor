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
#import "NoDraggableClassesView.h"
#import "HiddenInstancesListView.h"

@class Component;
@class PaletteItem;

@interface Component : UIView <UIGestureRecognizerDelegate, NoDraggableViewProtocol, HiddenInstancesListViewDelegate, NSCoding>{
    
    UITapGestureRecognizer * tapGR;
    UILongPressGestureRecognizer * longGR;
    UIPanGestureRecognizer * panGR;
    
    
    UIFont * font;
    AppDelegate * dele;

    UIPanGestureRecognizer * resizeGr;

    CAShapeLayer * backgroundLayer;
    
    //UIView * resizeView;
    
    float prevPinchScale;
    
    Component * sourceTemp;
    Component * targetTemp;
    
    PaletteItem * connectionToDo;
    
    NSString * tempClassName;
    float lastScale;
}


//@property NSString * name;
@property CATextLayer * textLayer;
@property NSString * type;
@property NSString * shapeType;
@property UIColor * fillColor;
@property NSString * colorString;
@property UIImage * image;
@property BOOL isImage;
@property BOOL isDragable;
@property NSString * componentId;
@property NSString * className;

@property NSMutableArray * attributes;
@property NSMutableArray * references;

@property NSString * name;


@property PaletteItem * parentItem;


//Node
@property NSString * borderColorString;
@property NSString * borderStyleString;
@property NSNumber * borderWidth;
@property UIColor * borderColor;

//Los cuatro siguientes son para buscar en el ecore

@property NSString * containerReference; //nombre de la referencia que lo contiene en la clase root. Sin parsear. Ejemplo: DFAAutomaton.ecore#//Automaton/alphabet

@property NSMutableArray * parentClassArray;

@property UIView * canvas;


-(CGPoint)getTopAnchorPoint;
-(CGPoint)getBotAnchorPoint;
-(CGPoint)getLeftAnchorPoint;
-(CGPoint)getRightAnchorPoint;

-(void)updateNameLabel;
-(void)fitNameLabel;
-(void)prepare;
@end
