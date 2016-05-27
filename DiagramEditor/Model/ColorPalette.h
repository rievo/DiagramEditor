//
//  ColorPalette.h
//  DiagramEditor
//
//  Created by Diego Vaquero Melchor on 11/12/15.
//  Copyright © 2015 Diego Vaquero Melchor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ColorPalette : NSObject

+(UIColor *)colorForString:(NSString *)str;

+(UIColor *)white;
+(UIColor *)black;
+(UIColor *)blue;
+(UIColor *)chocolate;
+(UIColor *)gray;
+(UIColor *)green;
+(UIColor *)orange;
+(UIColor *)purple;
+(UIColor *)red;
+(UIColor *)yellow;
+(UIColor *)lightBlue;
+(UIColor *)lightChocolate;
+(UIColor *)lightGray;
+(UIColor *)lightGreen;
+(UIColor *)lightOrange;
+(UIColor *)lightPurple;
+(UIColor *)lightRed;
+(UIColor *)lightYellow;
+(UIColor *)darkBlue;
+(UIColor *)darkChocolate;
+(UIColor *)darkGray;
+(UIColor *)darkOrange;
+(UIColor *)darkPurple;
+(UIColor *)darkRed;
+(UIColor *)darkYellow;
+(UIColor *)darkGreen;

+(NSMutableArray *)colorArray;
+ (void)shuffle:(NSMutableArray *)array;

@end
