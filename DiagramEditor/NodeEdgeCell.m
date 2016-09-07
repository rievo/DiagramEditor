//
//  NodeEdgeCell.m
//  DiagramEditor
//
//  Created by Diego on 7/9/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "NodeEdgeCell.h"

@implementation NodeEdgeCell

@synthesize picker, associatedClass;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    pickerOptions = [[NSMutableArray alloc] init];
    
    [pickerOptions addObject:@"Node"];
    [pickerOptions addObject:@"Edge"];
    
    [picker setDataSource:self];
    [picker setDelegate:self];
    
    associatedClass = nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
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
    return pickerOptions.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [pickerOptions objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // This method is triggered whenever the user makes a change to the picker selection.
    // The parameter named row and component represents what was selected.
    
    if(row == 0){ // Node
        associatedClass.visibleMode = 0;
    }else{ //Edge
        associatedClass.visibleMode = 1;
    }
}

@end
