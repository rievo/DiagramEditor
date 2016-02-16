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
    
    
    
    __weak IBOutlet UITableView *palettesTable;
    
    __weak IBOutlet UITableView *localFilesTable;
    NSMutableArray * localFilesArray;
    
    __weak IBOutlet UITableView *serverFilesTable;
    NSMutableArray * serverFilesArray;

    NSMutableArray * palettes;
    
    NSTimer * refreshTimer;
    __weak IBOutlet UIButton *folder;
    
    PasteView *rootView ;
    
    NSString * tempPaletteFile;
    
    BOOL loadingADiagram;
    NSString * content;
    UIActivityIndicatorView *activityIndicator;
}

@end
