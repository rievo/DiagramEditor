//
//  NoDraggableComponentView.h
//  DiagramEditor
//
//  Created by Diego on 22/2/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;
@class Component;

#import "PaletteItem.h"

@interface NoDraggableComponentView : UIView<UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate>{
    
    __weak IBOutlet UILabel *nodeTypeLabel;
    __weak IBOutlet UITableView *table;
    
    id delegate;
    __weak IBOutlet UIView *background;
    
    AppDelegate * dele;
    
    NSMutableArray * thisArray;
    __weak IBOutlet UIView *itemInfoGroup;
    __weak IBOutlet UITableView *attributesTable;
    __weak IBOutlet UIView *container;
    
    CGRect oldFrame;
    CGPoint outCenter;
    
    Component * temporalComponent;
}

- (IBAction)addCurrentNode:(id)sender;
- (IBAction)cancelItemInfo:(id)sender;
- (IBAction)confirmSaveNode:(id)sender;




@property NSString * elementName;
@property id delegate;
@property PaletteItem * paletteItem;

-(void)updateNameLabel;

@end


@protocol NoDraggableComponentview <NSObject>

@end