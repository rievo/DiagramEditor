//
//  RefineParametersViewController.h
//  DiagramEditor
//
//  Created by Diego on 7/9/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JsonClass.h"
#import "AppDelegate.h"
#import "EcoreFile.h"

@interface RefineParametersViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>{
    
    __weak IBOutlet UITableView *table;
    AppDelegate * dele;
}


@property NSMutableArray * nodes;
@property NSMutableArray * edges;

@property NSMutableArray * visibles;
@property NSMutableArray * hidden;

@property NSMutableArray * classes;

@property JsonClass * root;

@property EcoreFile * selectedJson;

@end
