//
//  NodeEdgeCell.m
//  DiagramEditor
//
//  Created by Diego on 7/9/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "NodeEdgeCell.h"

@implementation NodeEdgeCell

@synthesize picker, associatedClass, root;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    pickerOptions = [[NSMutableArray alloc] init];
    
    [pickerOptions addObject:@"Node"];
    [pickerOptions addObject:@"Edge"];
    
    [picker setDataSource:self];
    [picker setDelegate:self];
    

    
    [_referencesPicker setDataSource:self];
    [_referencesPicker setDelegate:self];
    
    associatedClass.visibleMode = 0;
    
}

-(void)fillReferences{
    containmentReferences = [[NSMutableArray alloc] init];
    
    
    NSArray * rootRefs = [root references];
    
    for(Reference * ref in rootRefs){
        NSString * line = [NSString stringWithFormat:@"%@/%@", root.name, ref.name];
        [containmentReferences addObject:line];
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)prepare{
    associatedClass.visibleMode = 0; //Default node
    [self fillReferences];
    
    NSInteger index = [_referencesPicker selectedRowInComponent:0];
    _selectedReference = [containmentReferences objectAtIndex:index];
     associatedClass.containmentReference = [containmentReferences objectAtIndex:index];
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
    if(pickerView == picker){
        return pickerOptions.count;
    }else if(pickerView == _referencesPicker){
        return containmentReferences.count;
    }else{
        return 0;
    }
    
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(pickerView == picker){
         return [pickerOptions objectAtIndex:row];
    }else if(pickerView == _referencesPicker){
        return [containmentReferences objectAtIndex:row];
    }else{
        return @"Empty";
    }
   
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // This method is triggered whenever the user makes a change to the picker selection.
    // The parameter named row and component represents what was selected.
    if(pickerView == picker){
        if(row == 0){ // Node
            associatedClass.visibleMode = 0;
        }else{ //Edge
            associatedClass.visibleMode = 1;
        }
    }else if(pickerView == _referencesPicker){
        _selectedReference = [containmentReferences objectAtIndex:row];
        associatedClass.containmentReference = [containmentReferences objectAtIndex:row];
    }
    
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
