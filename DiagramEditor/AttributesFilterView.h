//
//  AttributesFilterView.h
//  DiagramEditor
//
//  Created by Diego on 10/3/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;

@interface AttributesFilterView : UIView<UITableViewDataSource, UITableViewDelegate>{
    
    id delegate;
    __weak IBOutlet UISwitch *selectAllSwitch;
    __weak IBOutlet UITableView *atrributesTable;
    __weak IBOutlet UIView *background;
    
    AppDelegate * dele;
    __weak IBOutlet UILabel *label;
}


@property id delegate;

@property NSMutableArray * attrsArray;

- (IBAction)coseView:(id)sender;
-(void)prepare;

@end


@protocol AttributesFilterViewProtocol <NSObject>

-(void)closedAttributesFilterView;

@end
