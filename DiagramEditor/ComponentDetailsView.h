//
//  ComponentDetailsViewController.h
//  DiagramEditor
//
//  Created by Diego Vaquero Melchor on 9/12/15.
//  Copyright © 2015 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Component;
@class AppDelegate;


@interface ComponentDetailsView : UIView <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>{
    
    __weak IBOutlet Component *previewComponent;
    __weak IBOutlet UITextField *nameTextField;
    __weak IBOutlet UILabel *typeLabel;
    
    AppDelegate * dele;
    
    Component * temp;
    __weak IBOutlet UITableView *outConnectionsTable;
    __weak IBOutlet UITableView *attributesTable;
    
    NSMutableArray * connections;
    
    id delegate;
}

@property (nonatomic, retain)id delegate;

@property Component * comp;

- (void)prepare;
- (IBAction)closeDetailsViw:(id)sender;


@end;

@protocol ComponentDetailsViewDelegate

@required
-(void)closeDetailsViewAndUpdateThings;

@end
