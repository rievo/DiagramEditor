//
//  NodeVisualInfoTableViewCell.h
//  DiagramEditor
//
//  Created by Diego on 8/9/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NodeVisualInfoTableViewCell : UITableViewCell<UIPickerViewDelegate, UIPickerViewDataSource>{
    NSMutableArray * colors;
    NSMutableArray * shapes;
    NSMutableArray * borders;
}

@property (weak, nonatomic) IBOutlet UIPickerView *shapePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *fillColorPicker;
@property (weak, nonatomic) IBOutlet UITextField *widthTextField;
@property (weak, nonatomic) IBOutlet UITextField *HeightTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *borderStylePicker;
@end
