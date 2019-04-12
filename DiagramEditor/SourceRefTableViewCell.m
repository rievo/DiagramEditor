//
//  SourceRefTableViewCell.m
//  DiagramEditor
//
//  Created by Diego on 12/9/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "SourceRefTableViewCell.h"

@implementation SourceRefTableViewCell

@synthesize control, ref, isSource;


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code+
     [control addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)changeSwitch:(id)sender{
    
    Boolean val = [sender isOn];
    
    isSource = val;
}

@end
