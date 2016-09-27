//
//  Connection.h
//  DiagramEditor
//
//  Created by Diego Vaquero Melchor on 9/12/15.
//  Copyright © 2015 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reference.h"
@class Component;
@class PaletteItem;

@interface Connection : UIView<NSCoding>


//@property NSString * name;
@property Component * source;
@property Component * target;


@property UIBezierPath * arrowPath;

@property CGPoint controlPoint;

@property NSString * className;

@property NSMutableArray * attributes;

@property NSString * sourceDecorator;
@property NSString * targetDecorator;

@property NSMutableArray * references;

//Edge
@property NSNumber * lineWidth;
@property NSString * lineStyle;
@property UIColor * lineColor;
@property NSString * lineColorNameString;


@property BOOL isLinkPalette;
@property NSString * linkPaletteRefName;

@property NSMutableDictionary * instancesOfClassesDictionary;

-(void)retrieveAttributesForThisClassName;
-(void)retrieveConnectionGraphicInfoWithPaletteItem: (PaletteItem *) p;
-(NSString *)getName;

@end
