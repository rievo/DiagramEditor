//
//  Constants.h
//  DiagramEditor
//
//  Created by Diego on 15/3/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const SERVICE_NAME;


#pragma mark Decorators
FOUNDATION_EXPORT NSString *const NO_DECORATION;
FOUNDATION_EXPORT NSString *const INPUT_ARROW;
FOUNDATION_EXPORT NSString *const DIAMOND;
FOUNDATION_EXPORT NSString *const FILL_DIAMOND;
FOUNDATION_EXPORT NSString *const INPUT_CLOSED_ARROW;
FOUNDATION_EXPORT NSString *const INPUT_FILL_CLOSED_ARROW;
FOUNDATION_EXPORT NSString *const OUTPUT_ARROW;
FOUNDATION_EXPORT NSString *const OUTPUT_CLOSED_ARROW;
FOUNDATION_EXPORT NSString *const OUTPUT_FILL_CLOSED_ARROW;


#pragma mark Styles
FOUNDATION_EXPORT NSString *const SOLID;
FOUNDATION_EXPORT NSString *const DASH;
FOUNDATION_EXPORT NSString *const DOT;
FOUNDATION_EXPORT NSString *const DASH_DOT;


#pragma mark Decorators
#define decoratorSize 10


#pragma mark Scale nodes on editor view
#define scaleFactor 1.2f

@interface Constants : NSObject

@end
