//
//  HiddenInstancesListView.h
//  DiagramEditor
//
//  Created by Diego on 29/2/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Component;
@class Connection;


//Muestra las instancias ocultas de esta clase
@interface HiddenInstancesListView : UIView<UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>{
    
    __weak IBOutlet UIView *background;
    __weak IBOutlet UITableView *instancesTable;
    
    NSMutableArray * instancesArray;
    
    id delegate;
}

@property NSString * className;

@property id delegate;
@property Connection * connection;

-(void)reloadInfo;
@end



@protocol HiddenInstancesListViewDelegate <NSObject>

-(void)closeHILV: (UIView *)view
withSelectedComponent:(Component *)comp
   andConnection: (Connection *)conn;

@end
