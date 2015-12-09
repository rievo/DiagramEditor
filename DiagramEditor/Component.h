//
//  Component.h
//  DiagramEditor
//
//  Created by Diego Vaquero Melchor on 5/11/15.
//  Copyright © 2015 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"


@interface Component : UIView <UIGestureRecognizerDelegate>{
    
    UITapGestureRecognizer * tapGR;
    UILongPressGestureRecognizer * longGR;
    UIPanGestureRecognizer * panGR;
    
    
    UIFont * font;
    AppDelegate * dele;

    
    CATextLayer * textLayer;
    CAShapeLayer * backgroundLayer;
    
    
}


@property NSString * name;
@property NSMutableArray * connections;


-(CGPoint)getTopAnchorPoint;
-(CGPoint)getBotAnchorPoint;
-(CGPoint)getLeftAnchorPoint;
-(CGPoint)getRightAnchorPoint;

@end
