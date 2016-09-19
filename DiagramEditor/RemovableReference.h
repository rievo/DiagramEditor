//
//  RemovableReference.h
//  DiagramEditor
//
//  Created by Diego on 8/9/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "Reference.h"

@interface RemovableReference : Reference

@property Boolean isPresent;


@property NSString * color;
@property NSString * style;
@property NSString * sourceDecorator;
@property NSString * targetDecorator;

@end
