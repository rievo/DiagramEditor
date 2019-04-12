//
//  SelectEcoreViewController.h
//  DiagramEditor
//
//  Created by Diego on 7/9/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EcoreFile.h"
#import "AppDelegate.h"
@interface SelectEcoreViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>{
    
    __weak IBOutlet UITableView *ecoresTable;
    NSMutableArray * jsonsArray;
    
    EcoreFile * selectedJson;
    AppDelegate * dele;
    
    UIRefreshControl *refreshControl;
}

@end
