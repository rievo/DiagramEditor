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
    
    NSMutableArray * containmentReferences;
}

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *picker;
@property JsonClass * associatedClass;
@property (weak, nonatomic) IBOutlet UIPickerView *referencesPicker;

@property JsonClass * root;

@property NSString * selectedReference;

-(void)prepare;

@end
