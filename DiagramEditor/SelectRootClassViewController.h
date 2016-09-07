//
//  SelectRootClasViewController.h
//  DiagramEditor
//
//  Created by Diego on 7/9/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EcoreFile.h"
#import "AppDelegate.h"

@class JsonClass;

@interface SelectRootClassViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>{
    NSString * extension;
    NSMutableArray * classesArray;
    __weak IBOutlet UITableView *table;
    
    JsonClass * rootClass;
    AppDelegate * dele;
}

@property EcoreFile * selectedJson;

@end
