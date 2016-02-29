//
//  NoDraggableClassesView.h
//  DiagramEditor
//
//  Created by Diego on 29/2/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AppDelegate;
@class PaletteItem;
@class Connection;

@interface NoDraggableClassesView : UIView <UITableViewDataSource, UITableViewDelegate>{
    
    __weak IBOutlet UIView *background;
    __weak IBOutlet UITableView *table;
    AppDelegate * dele;
    
    id delegate;
}


@property NSMutableArray * itemsArray;
@property id delegate;
@property Connection * connection;

-(void)reloadInfo;

- (IBAction)cancelAssociatingComponent:(id)sender;

@end


@protocol NoDraggableViewProtocol <NSObject>

-(void)closeDraggableLisView: (UIView *)view
           WithReturnedItem:(PaletteItem *)value
               andConnection:(Connection * )conn;


@end