//
//  LinkPalette.h
//  DiagramEditor
//
//  Created by Diego on 14/6/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LinkPalette : NSObject<NSCoding>

@property NSString * anEReference;
@property NSString * lineStyle;
@property NSString * paletteName;
@property NSDictionary * colorDic;
@property NSString * targetDecoratorName;
@property NSString * sourceDecoratorName;
@property NSString * anDiagramElement;

@property NSString * className;
@property NSString * referenceInClass;

@property BOOL isExpandableItem;
@property int expandableIndex;

@property NSMutableArray * instances;

@end
