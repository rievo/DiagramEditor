//
//  Canvas.h
//  DiagramEditor
//
//  Created by Diego Vaquero Melchor on 9/12/15.
//  Copyright © 2015 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AppDelegate;
#import "YesOrNoView.h"
#import "Component.h"

@interface Canvas : UIView<YesOrNoDelegate>{
    AppDelegate * dele;
    
    UITapGestureRecognizer * tapGR;
    
    
    
    UIColor * fontColor;
    UIFont * font;
    
    UIColor * highlightColor;
}

@property double xArrowStart;
@property double yArrowStart;
@property double xArrowEnd;
@property double yArrowEnd;



-(void)prepareCanvas;

- (BOOL)isPoint:(CGPoint)p withinDistance:(CGFloat)distance ofPath:(CGPathRef)path;



+(UIBezierPath *)getInputArrowPath;
+(UIBezierPath *)getDiamondPath;
+(UIBezierPath *)getInputClosedArrowPath;
+(UIBezierPath *)getInputFillClosedArrowPath;
+(UIBezierPath *)getOutputArrowPath;
+(UIBezierPath *)getOutputClosedArrowPath;
+(UIBezierPath *)getNoDecoratorPath;

@end
