//
//  SessionUsersView.h
//  DiagramEditor
//
//  Created by Diego on 11/4/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AppDelegate;

@interface SessionUsersView : UIView <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>{
    
    
    AppDelegate * dele;
    NSMutableArray * usersArray;
    
    CGPoint goodCenter;
    __weak IBOutlet UIView *background;
    
    NSMutableDictionary * cells;
}

@property (weak, nonatomic) IBOutlet UITableView *table;
-(void)prepare;


@end
