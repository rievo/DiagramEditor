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


@interface ConfigureGraphicsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>{
    
    __weak IBOutlet UITableView *table;
    AppDelegate * dele;
}

@property NSMutableArray * nodes;
@property NSMutableArray * edges;

@property NSMutableArray * visibles;
@property NSMutableArray * hidden;

@property JsonClass * root;

@property NSMutableArray * classes;

@end
