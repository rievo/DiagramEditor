//
//  BooleanAttributeTableViewCell.m
//  DiagramEditor
//
//  Created by Diego on 25/1/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "BooleanAttributeTableViewCell.h"
#import "ClassAttribute.h"

@implementation BooleanAttributeTableViewCell

@synthesize nameLabel, switchValue, associatedAttribute;

- (void)awakeFromNib {
    // Initialization code
    
    [switchValue addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    
}
/*
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    if (switchValue.isOn == true) {
        associatedAttribute.currentValue = @"true";
    }else{
        associatedAttribute.currentValue = @"false";
    }
}*/

- (void)changeSwitch:(id)sender{
    if (switchValue.isOn == true) {
        associatedAttribute.currentValue = @"true";
    }else{
        associatedAttribute.currentValue = @"false";
    }
}
@end
