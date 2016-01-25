//
//  ExploreFilesView.h
//  DiagramEditor
//
//  Created by Diego on 25/1/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@protocol ExploreFilesDelegate
-(void)reactToFile:(NSString * )path;
@end

@interface ExploreFilesView : UIView <UITableViewDataSource, UITableViewDelegate>{
    NSMutableArray * files;
    id delegate;
    AppDelegate * dele;
    
    UITapGestureRecognizer * tapgr;
}

@property (nonatomic, retain) id delegate;
@property (weak, nonatomic) IBOutlet UITableView *filesTable;
@property (weak, nonatomic) IBOutlet UIView *background;

@end
