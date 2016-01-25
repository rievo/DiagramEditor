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
@property UIImage * image;
@property BOOL isImage;


@property NSString * className;

@property NSMutableArray * attributes;

@end
