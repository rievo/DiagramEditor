//
//  EdgeListView.h
//  DiagramEditor
//
//  Created by Diego on 4/2/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AppDelegate;
@class PaletteItem;


@interface EdgeListView : UIView<UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>{
    
    NSMutableArray * edges;
    AppDelegate * dele;
    id delegate;
}
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIView *background;

@property (nonatomic, retain) id delegate;

@end


@protocol EdgeListDelegate

@required

-(void) selectedEdge:(PaletteItem *)pi;

@end