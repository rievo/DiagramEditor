//
//  EdgeVisualInfoTableViewCell.h
//  DiagramEditor
//
//  Created by Diego on 9/9/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Connection.h"
@interface EdgeVisualInfoTableViewCell : UITableViewCell<UIPickerViewDelegate, UIPickerViewDataSource>{
    NSMutableArray * colors;
    NSMutableArray * sourceDecorators;
    NSMutableArray * targetDecorators;
    NSMutableArray * styles;
}

@property Connection * conn;
@property (weak, nonatomic) IBOutlet UIPickerView *strokeColorPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *lineStylePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *sourceDecoratorPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *targetDecoratorPicker;



@end
