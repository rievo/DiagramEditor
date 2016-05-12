//
//  ReferenceTableViewCell.m
//  DiagramEditor
//
//  Created by Diego on 26/1/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "ReferenceTableViewCell.h"

@implementation ReferenceTableViewCell

@synthesize nameLabel, containmentSwitch, minLabel, maxLabel, targetLabel;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
