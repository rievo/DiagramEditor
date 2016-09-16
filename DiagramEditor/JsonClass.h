//
//  JsonClass.h
//  DiagramEditor
//
//  Created by Diego on 7/9/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClassAttribute.h"
#import "Reference.h"
#import "Component.h"

@interface JsonClass : NSObject

@property NSString * name;
@property BOOL abstract;
@property NSMutableArray * parents; //String array
@property NSMutableArray * attributes; //ClassAtribute array
@property NSMutableArray * references; //Reference array

@property int visibleMode; //0 -> node  1-> Edge

@property NSString * containmentReference;

@property id associatedComponent;

@end
