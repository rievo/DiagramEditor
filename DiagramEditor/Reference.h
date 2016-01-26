//
//  Reference.h
//  DiagramEditor
//
//  Created by Diego on 26/1/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Reference : NSObject

@property NSString * name;
@property BOOL containment;
@property NSString * target;
@property NSString * opposite;
@property NSNumber * min;
@property NSNumber * max;


@end
