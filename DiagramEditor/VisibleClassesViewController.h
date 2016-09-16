//
//  VisibleClassesViewController.h
//  DiagramEditor
//
//  Created by Diego on 7/9/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JsonClass.h"
#import "AppDelegate.h"
#import "EcoreFile.h"

@interface VisibleClassesViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>{
    
    __weak IBOutlet UITableView *table;
    
    NSMutableArray * visibles;
    NSMutableArray * hidden;
    AppDelegate * dele;
    
    NSMutableArray * nodes;
    NSMutableArray * edges;
    
}
- (IBAction)cancelVisibleClasses:(id)sender;

@property NSMutableArray * classesArray;
@property JsonClass * root;


@property EcoreFile * selectedJson;


@end
