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
#import "ComponentDetailsView.h"
#import "ConnectionDetailsView.h"
#import "SaveNameView.h"
#import "SureView.h"
#import "EdgeListView.h"
#import "SessionUsersView.h"

@class Palette;
@class PaletteItem;
@class ComponentDetailsView;

#import <MessageUI/MFMailComposeViewController.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface EditorViewController : UIViewController<MFMailComposeViewControllerDelegate,
UIGestureRecognizerDelegate,
UIScrollViewDelegate,
ComponentDetailsViewDelegate,
SaveNameDelegate,
ConnectionDetailsViewDelegate,
SureViewDelegate,
EdgeListDelegate, MCBrowserViewControllerDelegate>{
    AppDelegate * dele;
    __weak IBOutlet Palette *palette;
    
    PaletteItem * tempIcon;
    __weak IBOutlet UIButton *newDiagram;
    __weak IBOutlet UIButton *saveDiagram;
    
    MFMailComposeViewController* controller ;
    
    
    Canvas *canvas;
    
    int canvasW;
    
    
    //Button outlets
   // __weak IBOutlet UIButton *saveButton;
    
    
    
    int zoomLevel; //0-> No zoom     1-> mid zoom   2-> Full zoom
    
    ComponentDetailsView * compDetView;
    UIView * containerView;
    
    UIView * saveBackgroundBlackView;
    SaveNameView * snv;
    
    NSString * textToSave;
    NSString * oldFileName;
    
    __weak IBOutlet UIButton *cameraOutlet;
    
    
    SureView * sureView;
    //__weak IBOutlet UISlider *slider;
    __weak IBOutlet UIButton *shareButtonOutlet;
    
    
    BOOL sharingDiagram;
    
    NSTimer * resendTimer;
    
    
    __weak IBOutlet UIButton *showHidePaletteOutlet;
    BOOL isPaletteCollapsed;
    
    CGPoint paletteCenter;
    
    CGRect paletteRect;
    CGRect collapsedRect;
    
    __weak IBOutlet UIButton *collaborationButton;
    
    SessionUsersView *usersListView;
    __weak IBOutlet UIButton *showUsersPeersViewButton;
    

    __weak IBOutlet UIButton *askForMasterButton;
    
    
    
    BOOL showingPossibleAlerts;
    __weak IBOutlet UIButton *alerts;
    __weak IBOutlet UIImageView *exclamationAlert;
    __weak IBOutlet UIImageView *interrogationAlert;
    __weak IBOutlet UIImageView *noteAlert;
    __weak IBOutlet UIImageView *drawAlert;
    __weak IBOutlet UIImageView *arrowAlert;
    
    UIImageView * temporalAlertIcon;
    
    CGRect exclamationFrame;
    CGRect interrogationFrame;
    CGRect arrowFrame;
    CGRect drawFrame;
    CGRect noteFrame;
    
    
    CGPoint alertsCenter;
    CGPoint exclamationCenter;
    CGPoint interrogationCenter;
    CGPoint arrowCenter;
    CGPoint drawCenter;
    CGPoint noteCenter;
    
    __weak IBOutlet UIButton *chatButton;
    
    NSString * tempNoteContent;
    NSString * noteToShow;
    MCPeerID * whoSendTheNote;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property NSString * loadedContent;


- (IBAction)shareDiagram:(id)sender;


- (IBAction)showComponentList:(id)sender;
- (IBAction)showActionsList:(id)sender;
- (IBAction)createNewDiagram:(id)sender;


- (IBAction)saveCurrentDiagram:(id)sender;
- (IBAction)exportCanvasToImage:(id)sender;

- (IBAction) valueChanged:(id)sender event:(UIControlEvents)event ;

- (IBAction)expandOrCollapsePalette:(id)sender;

- (IBAction)iWantToBeTheNewMaster:(id)sender;

- (IBAction)showUsersList:(id)sender;
- (IBAction)showPossibleAlerts:(id)sender;

- (IBAction)showChat:(id)sender;
@end
