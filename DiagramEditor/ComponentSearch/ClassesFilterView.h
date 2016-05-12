//
//  ClassesFilterView.h
//  DiagramEditor
//
//  Created by Diego on 10/3/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;

@interface ClassesFilterView : UIView<UITableViewDataSource, UITableViewDelegate>{
    
    __weak IBOutlet UISwitch *selectAllSwitch;
    __weak IBOutlet UITableView *classesTable;
    
    id delegate;
    __weak IBOutlet UILabel *selectAllClassesLabel;
    
    AppDelegate * dele;
    
    
    
}

@property id delegate;
@property (weak, nonatomic) IBOutlet UIView *background;


@property NSMutableArray * classesArray;

- (IBAction)closeClassesFilterView:(id)sender;
-(void)prepare;

@end


@protocol ClassesFilterViewProtocol <NSObject>

-(void)closedClassedFilterView;


@end
