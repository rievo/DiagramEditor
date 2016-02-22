//
//  NoDraggableComponentView.h
//  DiagramEditor
//
//  Created by Diego on 22/2/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;

@interface NoDraggableComponentView : UIView<UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate>{
    
    __weak IBOutlet UILabel *nodeTypeLabel;
    __weak IBOutlet UITableView *table;
    __weak IBOutlet UITextField *textField;
    
    id delegate;
    __weak IBOutlet UIView *background;
    
    AppDelegate * dele;
    
    NSMutableArray * thisArray;
}

- (IBAction)addCurrentNode:(id)sender;


@property NSString * elementName;
@property id delegate;

-(void)updateNameLabel;

@end


@protocol NoDraggableComponentview <NSObject>

@end