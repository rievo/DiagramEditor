//
//  EnumTableViewCell.h
//  DiagramEditor
//
//  Created by Diego on 20/10/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClassAttribute.h"
#import "Component.h"

@interface EnumTableViewCell : UITableViewCell <UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) IBOutlet UIPickerView *optionsPicker;
@property ClassAttribute * associatedAttribute;
@property Component * comp;
@property Component * previewComp;

@property NSArray * options;

-(void)prepare;
@end
