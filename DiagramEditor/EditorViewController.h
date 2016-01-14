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

#import <MessageUI/MFMailComposeViewController.h>

@interface EditorViewController : UIViewController<MFMailComposeViewControllerDelegate, UIScrollViewDelegate>{
    AppDelegate * dele;
    __weak IBOutlet Palette *palette;
    
    PaletteItem * tempIcon;
    __weak IBOutlet UIButton *newDiagram;
    __weak IBOutlet UIButton *saveDiagram;
    
    
    __weak IBOutlet UIView *sureCloseView;
    UIView * backSure;
    
    MFMailComposeViewController* controller ;
    
    
    Canvas *canvas;
    
    int canvasW;
    
    
    //Button outlets
    __weak IBOutlet UIButton *saveButton;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)addElement:(id)sender;
- (IBAction)showComponentList:(id)sender;
- (IBAction)showActionsList:(id)sender;
- (IBAction)createNewDiagram:(id)sender;
- (IBAction)sureCreateNew:(id)sender;
- (IBAction)notSureCreateNew:(id)sender;

- (IBAction)saveCurrentDiagram:(id)sender;
- (IBAction)exportCanvasToImage:(id)sender;
@end
