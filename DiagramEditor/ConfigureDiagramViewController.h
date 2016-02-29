//
//  ConfigureDiagramViewController.h
//  DiagramEditor
//
//  Created by Diego Vaquero Melchor on 9/12/15.
//  Copyright © 2015 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PasteView.h"
#import "ExploreFilesView.h"
@class AppDelegate;
@class Palette;


@interface ConfigureDiagramViewController : UIViewController<UIScrollViewDelegate, UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate, PasteViewDelegate, ExploreFilesDelegate>{
    NSDictionary * configuration;
    AppDelegate * dele;
    __weak IBOutlet UIScrollView *scrollView;
    __weak IBOutlet UIView *infoView;
    __weak IBOutlet UILabel *infoLabel;
    
    CGRect initialInfoPosition;
    __weak IBOutlet Palette *palette;
    
    
    
    __weak IBOutlet UITableView *filesTable;
    NSMutableArray * filesArray; //Server and local palettes
    
    
    __weak IBOutlet UITableView *palettesTable;
    

    NSMutableArray * palettes;
    
    NSTimer * refreshTimer;
    __weak IBOutlet UIButton *folder;
    
    PasteView *rootView ;
    
    NSString * tempPaletteFile;
    
    BOOL loadingADiagram;
    NSString * content;
    UIActivityIndicatorView *activityIndicator;
    
    
    
    __weak IBOutlet UIView *paletteFileGroup;
    __weak IBOutlet UIView *subPaletteGroup;
    __weak IBOutlet UIButton *cancelSubpaletteSelectionOutlet;
    
    CGRect oldPaletteFileGroupFrame;
    CGRect oldSubPaletteGroupFrame;
    __weak IBOutlet UIButton *confirmButton;
    
}
- (IBAction)cancelSubpaletteSelection:(id)sender;
- (IBAction)reloadServerPalettes:(id)sender;


@end
