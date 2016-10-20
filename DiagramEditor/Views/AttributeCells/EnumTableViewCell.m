//
//  EnumTableViewCell.m
//  DiagramEditor
//
//  Created by Diego on 20/10/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "EnumTableViewCell.h"

@implementation EnumTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _optionsPicker.delegate = self;
    _optionsPicker.dataSource = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)prepare{
    //Select current option
    
    for(int i  = 0; i< _options.count; i++){
        NSString * temp = [_options objectAtIndex:i];
        if([temp isEqualToString:_associatedAttribute.currentValue]){
            [_optionsPicker selectRow:i inComponent:0 animated:NO];
        }
    }
}



#pragma mark UIPickerView methods

// The number of columns of data
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _options.count;
    
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [_options objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // This method is triggered whenever the user makes a change to the picker selection.
    // The parameter named row and component represents what was selected.
    _associatedAttribute.currentValue = [_options objectAtIndex:row];
    
    
    
    [_comp updateNameLabel];
    
    //Update preview
    for(ClassAttribute * temp in _previewComp.attributes){
        if([temp.name isEqualToString:_associatedAttribute.name]){
            temp.currentValue = _associatedAttribute.currentValue;
        }
    }
    [_previewComp updateNameLabel];
    [_previewComp setNeedsDisplay];
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel* tView = (UILabel*)view;
    if (!tView)
    {
        tView = [[UILabel alloc] init];
        
        tView.textAlignment = NSTextAlignmentCenter;
        
        tView.adjustsFontSizeToFitWidth = YES;
        // Setup label properties - frame, font, colors etc
    }
    
    tView.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    //Add any logic you want here
    
    return tView;
}

@end

