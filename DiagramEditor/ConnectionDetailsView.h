//
//  ConnectionDetailsView.h
//  DiagramEditor
//
//  Created by Diego on 26/1/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ConnectionDetailsViewDelegate <NSObject>

@required


@end

@class Connection;

@interface ConnectionDetailsView : UIView<UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>{
    id delegate;
    NSMutableArray * associatedComponentsArray;
    __weak IBOutlet UITableView *instancesTable;
    
    NSMutableArray * attributesArray;
    __weak IBOutlet UITableView *attributesTable;
}

@property (nonatomic, retain) id delegate;

//@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (weak, nonatomic) IBOutlet UILabel *sourceLabel;

@property (weak, nonatomic) IBOutlet UILabel *targetLabel;

//@property (weak, nonatomic) IBOutlet UITableView *attributesTable;
@property (weak, nonatomic) IBOutlet UIView *background;


@property Connection * connection;

- (IBAction)removeThisConnection:(id)sender;

- (IBAction)associateNewInstance:(id)sender;
-(void)prepare;
@end
