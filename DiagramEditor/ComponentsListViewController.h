//
//  ComponentsListViewController.h
//  DiagramEditor
//
//  Created by Diego Vaquero Melchor on 17/12/15.
//  Copyright © 2015 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AppDelegate;


@interface ComponentsListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>{
    
    AppDelegate * dele;
    __weak IBOutlet UITableView *componentsTable;
    
    __weak IBOutlet UISearchBar *searchBar;
    
    NSMutableArray * filteredArray;
    BOOL isFiltered;
}

- (IBAction)closeList:(id)sender;
@end
