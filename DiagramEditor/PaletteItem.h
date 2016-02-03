//
//  PaletteItem.h
//  DiagramEditor
//
//  Created by Diego Vaquero Melchor on 10/12/15.
//  Copyright © 2015 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaletteItem : UIView


@property NSString * type;
@property NSString * dialog;
@property NSNumber * width;
@property NSNumber * height;
@property NSString * shapeType;
@property UIColor * fillColor;
@property NSString * colorString;
@property UIImage * image;
@property BOOL isImage;


@property NSString * className; //La clase del item

@property NSMutableArray * attributes;


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

@end
