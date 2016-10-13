//
//  DoubleTableViewCell.h
//  DiagramEditor
//
//  Created by Diego on 13/10/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClassAttribute.h"
#import "Component.h"



@interface DoubleTableViewCell : UITableViewCell <UITextFieldDelegate>{
    
}

@property ClassAttribute * associatedAttribute;
@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UILabel *label;
@property Component * comp;
@end
