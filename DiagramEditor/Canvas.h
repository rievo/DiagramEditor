//
//  Canvas.h
//  DiagramEditor
//
//  Created by Diego Vaquero Melchor on 9/12/15.
//  Copyright © 2015 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AppDelegate;
#import "Component.h"

@interface Canvas : UIView{
    AppDelegate * dele;
}

@property double xArrowStart;
@property double yArrowStart;
@property double xArrowEnd;
@property double yArrowEnd;



-(void)prepareCanvas;
@end
