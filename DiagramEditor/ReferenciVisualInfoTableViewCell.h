//
//  ReferenciVisualInfoTableViewCell.h
//  DiagramEditor
//
//  Created by Diego on 8/9/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemovableReference.h"
@interface ReferenciVisualInfoTableViewCell : UITableViewCell<UIPickerViewDelegate, UIPickerViewDataSource>{
    NSMutableArray * colors;
    NSMutableArray * sourceDecorators;
    NSMutableArray * targetDecorators;
    NSMutableArray * styles;
}



@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UIPickerView *colorPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *stylePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *sourceDecoratorPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *targetDecoratorPicker;


@property RemovableReference * ref;

-(void)prepare;
@end
