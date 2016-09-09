//
//  SubsetionTableViewCell.m
//  DiagramEditor
//
//  Created by Diego on 7/9/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "SubsetionTableViewCell.h"

@implementation SubsetionTableViewCell

@synthesize control;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [control addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];

    
}

- (void)changeSwitch:(id)sender{
    
    Boolean val = [sender isOn];
    
    
    if([_associatedElement isKindOfClass:[ClassAttribute class]]){
        ClassAttribute * temp = _associatedElement;
        temp.isLabel = val;
    }else if([_associatedElement isKindOfClass:[RemovableReference class]]){
        RemovableReference * temp = _associatedElement;
        temp.isPresent = val;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
