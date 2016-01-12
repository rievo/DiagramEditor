//
//  PItemEditor.h
//  DiagramEditor
//
//  Created by Diego Vaquero Melchor on 12/1/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AppDelegate;

@interface PItemEditor : UIView{
    UIBezierPath * path;

    CGPoint pts[5];
    uint ctr;
    
    AppDelegate * dele;
}

@property UIImage * incrementalImage;



-(void)prepareEditor;

@end
