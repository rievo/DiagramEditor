//
//  IntegerTableViewCell.h
//  DiagramEditor
//
//  Created by Diego on 13/10/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClassAttribute.h"
#import "Component.h"


@interface IntegerTableViewCell : UITableViewCell<UITextFieldDelegate>

@property Component * comp;
@property ClassAttribute * associatedAttribute;
@property (strong, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) IBOutlet UITextField *textField;

@end
