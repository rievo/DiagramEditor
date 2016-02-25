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

@synthesize textField, attributeNameLabel, comp, detailsPreview, associatedAttribute;

- (void)awakeFromNib {
    // Initialization code
    
    //Si tiene ya valor dado este atributo, se lo damos al texto
    /*for(ClassAttribute * atr in comp.attributes){
     if([atr.name isEqualToString:attributeNameLabel.text]){
     textField.text =  atr.currentValue ;
     }
     }*/
    
    [comp updateNameLabel];
    [detailsPreview setNeedsDisplay];
    [detailsPreview updateNameLabel];
    
    
    
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
        [detailsPreview setNeedsDisplay];
        [detailsPreview updateNameLabel];
    }
}


-(BOOL)textField:(UITextField *)tf
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string{
    
    
    
    NSString * newVal = [tf.text stringByReplacingCharactersInRange:range withString:string];
    //if(newLength > 0){
    /*for(ClassAttribute * atr in comp.attributes){
        if([atr.name isEqualToString:attributeNameLabel.text]){
            atr.currentValue =[tf.text stringByReplacingCharactersInRange:range withString:string];
            comp.name = atr.currentValue;
            detailsPreview.name = atr.currentValue;
        }
    }*/
    
    associatedAttribute.currentValue = newVal;
    if([associatedAttribute.name isEqualToString:attributeNameLabel.text]){
        comp.name = associatedAttribute.currentValue;
        detailsPreview.name = associatedAttribute.currentValue;
    }
    
    [comp updateNameLabel];
    [detailsPreview setNeedsDisplay];
    [detailsPreview updateNameLabel];
    return YES;
    //}else
    //    return NO;
}

-(BOOL)textFieldShouldReturn:(UITextField *)tf
{
    //if(tf.text.length == 0){
    //    return NO;
    //}else{
    [tf resignFirstResponder];
    return YES;
    //}
    
}

@end
