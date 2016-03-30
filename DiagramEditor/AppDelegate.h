//
//  AppDelegate.h
//  DiagramEditor
//
//  Created by Diego Vaquero Melchor on 9/12/15.
//  Copyright © 2015 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MCManager.h"
#import "Constants.h"

@class Canvas;
@class Component;
@class EditorViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@property NSMutableArray * connections;
@property NSMutableArray * components;
@property NSMutableDictionary * elementsDictionary;

@property NSMutableArray * paletteItems;


@property UIColor * blue0;
@property UIColor * blue1;
@property UIColor * blue2;
@property UIColor * blue3;
@property UIColor * blue4;

@property Canvas * can;
@property EditorViewController * evc;
@property CGRect originalCanvasRect;

@property NSString * currentPaletteFileName;
@property NSString * subPalette;


@property NSDictionary * graphicR;


//Generate XML
@property NSString * graphicRContent;
@property NSString * ecoreContent;


//Multipeer Connectivity
@property MCManager * manager;

//Stream
@property NSOutputStream * output;


-(int)getOutConnectionsForComponent: (Component *)comp
                             ofType: (NSString * )type;
-(int)getInConnectionsForComponent: (Component *)comp
                             ofType: (NSString * )type;


-(NSData *) packElementsInfo;
-(void)recoverInfoFromData: (NSData *)data;



@end

