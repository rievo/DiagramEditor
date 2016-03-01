//
//  CloudDiagramsExplorer.h
//  DiagramEditor
//
//  Created by Diego on 1/3/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AppDelegate;
@class DiagramFile;

@interface CloudDiagramsExplorer : UIView <UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate>{
    
    
    __weak IBOutlet UIView *background;
    __weak IBOutlet UITableView *table;
    
    NSMutableArray * filesArray;
    
    AppDelegate * dele;
    
    
    id delegate;
}


@property id delegate;
@end




@protocol CloudDiagramsExplorer <NSObject>

-(void)closeExplorerWithSelectedDiagramFile: (DiagramFile *) file;

@end