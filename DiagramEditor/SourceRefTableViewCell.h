//
//  SourceRefTableViewCell.h
//  DiagramEditor
//
//  Created by Diego on 12/9/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Reference.h"

@interface SourceRefTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UISwitch *control;

@property Reference * ref;
@property BOOL isSource;

@end
