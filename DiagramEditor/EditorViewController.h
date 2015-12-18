//
//  EditorViewController.h
//  DiagramEditor
//
//  Created by Diego Vaquero Melchor on 9/12/15.
//  Copyright © 2015 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Component.h"
#import "AppDelegate.h"
#import "Canvas.h"


@class Palette;
@class PaletteItem;


@interface EditorViewController : UIViewController{
    AppDelegate * dele;
    __weak IBOutlet Palette *palette;
    
    PaletteItem * tempIcon;
    __weak IBOutlet UIButton *newDiagram;
    __weak IBOutlet UIButton *saveDiagram;
}

@property (weak, nonatomic) IBOutlet Canvas *canvas;

- (IBAction)addElement:(id)sender;
- (IBAction)showComponentList:(id)sender;
- (IBAction)showActionsList:(id)sender;
- (IBAction)createNewDiagram:(id)sender;

@end
