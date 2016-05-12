//
//  RowSwitchTableViewCell.h
//  DiagramEditor
//
//  Created by Diego on 10/3/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RowSwitchTableViewCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UISwitch *switchValue;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property NSMutableDictionary * dictionary;

@end
