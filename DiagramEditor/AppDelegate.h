//
//  AppDelegate.h
//  DiagramEditor
//
//  Created by Diego Vaquero Melchor on 9/12/15.
//  Copyright © 2015 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Canvas;
@class Component;
@class EditorViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@property NSMutableArray * connections;
@property NSMutableArray * components;

@property NSMutableArray * paletteItems;


@property UIColor * blue3;
@property UIColor * blue4;

@property Canvas * can;
@property EditorViewController * evc;
@property CGRect originalCanvasRect;

@property NSString * currentPaletteFileName;
@property NSString * subPalette;


@property NSDictionary * graphicR;


-(int)getOutConnectionsForComponent: (Component *)comp;
@end

