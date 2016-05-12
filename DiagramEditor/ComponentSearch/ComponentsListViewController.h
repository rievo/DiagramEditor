//
//  ComponentsListViewController.h
//  DiagramEditor
//
//  Created by Diego Vaquero Melchor on 17/12/15.
//  Copyright © 2015 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ClassesFilterView.h"
#import "AttributesFilterView.h"
#import "Component.h"



@class AppDelegate;


@interface ComponentsListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, ClassesFilterViewProtocol, AttributesFilterViewProtocol>{
    
    AppDelegate * dele;
    __weak IBOutlet UITableView *componentsTable;
    
    __weak IBOutlet UISearchBar *searchBar;
    
    NSMutableArray * filteredArray;
    BOOL isFiltered;
    
    
    ClassesFilterView * classFilter;
    AttributesFilterView * attrFilter;
    
    NSMutableArray * classesArray; //Array de diccionarios
    NSMutableArray * attrsArray;
    
    
    
    NSMutableArray * allElementsArray;
    
    
    
    BOOL attrFilterEnabled;
    
}
- (IBAction)showClassesFilter:(id)sender;
- (IBAction)showAttributesFilter:(id)sender;

- (IBAction)closeList:(id)sender;
@end
