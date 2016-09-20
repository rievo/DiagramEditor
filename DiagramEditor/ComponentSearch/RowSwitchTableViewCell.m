//
//  RowSwitchTableViewCell.m
//  DiagramEditor
//
//  Created by Diego on 10/3/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "RowSwitchTableViewCell.h"

@implementation RowSwitchTableViewCell

@synthesize nameLabel, switchValue, dictionary;



/*
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    }*/

- (IBAction)changeValue:(id)sender {

    BOOL newValue = switchValue.isOn;
    
    NSArray * keys = [dictionary allKeys];
    NSString * className = keys[0];
    
    [dictionary setValue:[NSNumber numberWithBool:newValue] forKey:className];

}

@end
