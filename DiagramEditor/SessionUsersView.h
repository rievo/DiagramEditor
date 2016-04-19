//
//  SessionUsersView.h
//  DiagramEditor
//
//  Created by Diego on 11/4/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AppDelegate;

@interface SessionUsersView : UIView <UITableViewDelegate, UITableViewDataSource>{
    
    
    AppDelegate * dele;
    NSMutableArray * usersArray;
    
    CGPoint goodCenter;
}

@property (weak, nonatomic) IBOutlet UITableView *table;
-(void)prepare;

@property BOOL isHidden;
@end
