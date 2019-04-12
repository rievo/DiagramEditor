//
//  ExpandableItemView.h
//  DiagramEditor
//
//  Created by Diego on 16/6/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Component;
#import "LinkPalette.h"
#import "AppDelegate.h"

@interface ExpandableItemView : UIView<UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>{
    
    __weak IBOutlet UITableView *table;
    __weak IBOutlet UILabel *titleLabel;
    AppDelegate * dele;

    __weak IBOutlet UIView *createInstanceView;
    __weak IBOutlet UILabel *classLabel;
    
    Component * creatingComponent;
    __weak IBOutlet UITableView *componentTable;
}


@property (weak, nonatomic) IBOutlet UIView *background;

@property Component * comp;
@property LinkPalette * lp;

- (IBAction)addNewItem:(id)sender;


-(void)prepare;
-(void)setTitle:(NSString *)title;

- (IBAction)cancelInstanceCreation:(id)sender;

- (IBAction)confirmInstanceCreation:(id)sender;


@end
