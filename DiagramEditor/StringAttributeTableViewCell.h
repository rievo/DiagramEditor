//
//  AttributeTableViewCell.h
//  DiagramEditor
//
//  Created by Diego on 22/1/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Component.h"
@interface StringAttributeTableViewCell : UITableViewCell<UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *attributeNameLabel;
@property Component * comp;
@property Component * detailsPreview;

@end
