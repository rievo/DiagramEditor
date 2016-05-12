//
//  ChatTableViewCell.m
//  ChatTest
//
//  Created by Diego on 10/5/16.
//  Copyright © 2016 Diego. All rights reserved.
//

#import "ChatTableViewCell.h"

@implementation ChatTableViewCell

@synthesize textLabel, whoLabel;


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    textLabel.numberOfLines = 0;
    textLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
