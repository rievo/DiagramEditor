//
//  ConfigureGraphicsViewController.h
//  DiagramEditor
//
//  Created by Diego on 8/9/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JsonClass.h"
#import "AppDelegate.h"
#import "EcoreFile.h"
#import "NodeVisualInfoTableViewCell.h"

@interface ConfigureGraphicsViewController : UIViewController<UITableViewDelegate,
UITableViewDataSource,
NodeVisualInfoDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate>{
    
    __weak IBOutlet UITableView *table;
    AppDelegate * dele;
    UIImagePickerController * picker;
    UIPopoverController *popover ;
    
    
    NodeVisualInfoTableViewCell * updatingCell;
}

@property NSMutableArray * nodes;
@property NSMutableArray * edges;

@property NSMutableArray * visibles;
@property NSMutableArray * hidden;

@property JsonClass * root;

@property NSMutableArray * classes;

@property EcoreFile * selectedJson;

@end
