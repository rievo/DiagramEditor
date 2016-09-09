//
//  SlideMenuView.h
//  DiagramEditor
//
//  Created by Diego on 9/9/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AppDelegate;

@interface SlideMenuView : UIView<UITableViewDelegate, UITableViewDataSource>{
    
    __weak IBOutlet UITableView *table;
    
    AppDelegate * dele;
    
    id delegate;
}

@property id delegate;

@end
@protocol SlideMenuDelegate <NSObject>

-(void)menuSelectedOption:(int)option;

@end