//
//  BooleanAttributeTableViewCell.h
//  DiagramEditor
//
//  Created by Diego on 25/1/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BooleanAttributeTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UISwitch *switchValue;

@end
