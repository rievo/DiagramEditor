//
//  NodeEdgeCell.h
//  DiagramEditor
//
//  Created by Diego on 7/9/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JsonClass.h"
@interface NodeEdgeCell : UITableViewCell<UIPickerViewDelegate, UIPickerViewDataSource>{
    NSMutableArray * pickerOptions;
}

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *picker;
@property JsonClass * associatedClass;

@end
