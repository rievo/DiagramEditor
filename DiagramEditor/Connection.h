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

@interface Connection : UIView


@property NSString * name;
@property Component * source;
@property Component * target;

@property CGRect touchRect;
@property UIBezierPath * arrowPath;

@property CGPoint controlPoint;

@property NSString * className;

@property NSMutableArray * attributes;

@end
