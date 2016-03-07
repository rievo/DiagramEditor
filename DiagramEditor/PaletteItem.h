//
//  PaletteItem.h
//  DiagramEditor
//
//  Created by Diego Vaquero Melchor on 10/12/15.
//  Copyright © 2015 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Component;


@interface PaletteItem : UIView <NSCoding>


@property NSString * type;
@property NSString * dialog;
@property NSNumber * width;
@property NSNumber * height;
@property NSString * shapeType;
@property UIColor * fillColor;
@property NSString * colorString; //Fill
@property UIImage * image;
@property BOOL isImage;
@property BOOL isDragable;


//Edge
@property NSNumber * lineWidth;
@property NSString * lineStyle;
@property UIColor * lineColor;
@property NSString * lineColorNameString;


@property NSString * className; //La clase del item

@property NSMutableArray * attributes;
@property NSMutableArray * references;


//For edges
@property NSString * edgeStyle;
@property NSString * sourceDecoratorName;
@property NSString * targetDecoratorName;

//Los cuatro siguientes son para buscar en el ecore
@property NSString * sourceName;
@property NSString * targetName;
@property NSString * sourcePart; //atributo de la clase sourceName
@property NSString * targetPart; //atributo de la clase targetName

@property NSString * sourceClass; //La clase que se permite en el origen
@property NSString * targetClass; //La clase que se permite en el destino

@property NSNumber * minOutConnections;
@property NSNumber * maxOutConnections;


@property NSString * containerReference; //nombre de la referencia que lo contiene en la clase root. Sin parsear. Ejemplo: DFAAutomaton.ecore#//Automaton/alphabet

@property NSMutableArray * parentsClassArray; //Array con las clases de las que herada  (en el caso de que lo haga)


-(Component *)getComponentForThisPaletteItem;
@end
