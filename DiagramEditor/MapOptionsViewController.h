//
//  MapOptionsViewController.h
//  DiagramEditor
//
//  Created by Diego on 6/10/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface MapOptionsViewController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource,UISearchBarDelegate>{
    
    IBOutlet UIPickerView *mapTypePicker;
    NSMutableArray * mapTypes;
    AppDelegate * dele;
    IBOutlet UISearchBar *directionSearchBar;
}
- (IBAction)closeMapOptions:(id)sender;
- (IBAction)testFlyover:(id)sender;

@end
