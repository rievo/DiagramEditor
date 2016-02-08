//
//  AttributeTableViewCell.m
//  DiagramEditor
//
//  Created by Diego on 22/1/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "StringAttributeTableViewCell.h"
#import "ClassAttribute.h"

@implementation StringAttributeTableViewCell

@synthesize textField, attributeNameLabel, comp;

- (void)awakeFromNib {
    // Initialization code
    
    //Si tiene ya valor dado este atributo, se lo damos al texto
    for(ClassAttribute * atr in comp.attributes){
        if([atr.name isEqualToString:attributeNameLabel.text]){
            textField.text =  atr.currentValue ;
        }
    }
    [comp updateNameLabel];
    
    [textField setDelegate:self];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}



#pragma mark UITextField delegate methods
- (void)textFieldDidEndEditing:(UITextField *)tf{
    
    if(tf.text.length > 0){
        
        for(ClassAttribute * atr in comp.attributes){
            if([atr.name isEqualToString:attributeNameLabel.text]){
                atr.currentValue = tf.text;
            }
        }
        [comp updateNameLabel];
    }
}


-(BOOL)textField:(UITextField *)tf
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string{
    
    NSInteger newLength =tf.text.length + string.length -range.length;

    
    if(newLength > 0){
        for(ClassAttribute * atr in comp.attributes){
            if([atr.name isEqualToString:attributeNameLabel.text]){
                atr.currentValue = tf.text;
                comp.name = atr.currentValue;
            }
        }
        [comp updateNameLabel];
        return YES;
    }else
        return NO;
}

-(BOOL)textFieldShouldReturn:(UITextField *)tf
{
    [tf resignFirstResponder];
    return YES;
}

@end
