//
//  NodeVisualInfoTableViewCell.m
//  DiagramEditor
//
//  Created by Diego on 8/9/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "NodeVisualInfoTableViewCell.h"

@implementation NodeVisualInfoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    shapes = [[NSMutableArray alloc] init];
    colors = [[NSMutableArray alloc] init];
    borders = [[NSMutableArray alloc] init];
    
    [self fillColors];
    [self fillBorders];
    [self fillShapes];
    
    [_shapePicker setDelegate:self];
    [_shapePicker setDataSource:self];
    
    [_fillColorPicker setDelegate:self];
    [_fillColorPicker setDataSource:self];
    
    [_borderStylePicker setDelegate:self];
    [_borderStylePicker setDataSource:self];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)fillShapes{
    [shapes addObject:@"Ellipse"];
    [shapes addObject:@"Rectangle"];
    [shapes addObject:@"Diamond"];
    [shapes addObject:@"Note"];
}

-(void)fillBorders{
    
    [borders addObject:@"solid"];
    [borders addObject:@"dash"];
    [borders addObject:@"dot"];
    [borders addObject:@"dash_dot"];
}

-(void)fillColors{
    colors = [[NSMutableArray alloc] initWithObjects:
              @"black",
              @"white",
              @"blue",
              @"chocolate",
              @"gray",
              @"green",
              @"orange",
              @"purple",
              @"red",
              @"yellow",
              @"lightBlue",
              @"lightChocolate",
              @"lightGray",
              @"lightGreen",
              @"lightOrange",
              @"lightPurple",
              @"lightRed",
              @"lightYellow",
              @"darkBlue",
              @"darkChocolate",
              @"darkGray",
              @"darkOrange",
              @"darkPurple",
              @"darkRed",
              @"darkYellow",
              @"darkGreen",nil];
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
    if(pickerView == _shapePicker){
        return  shapes.count;
    }else if(pickerView == _fillColorPicker){
        return colors.count;
    }else if(pickerView == _borderStylePicker){
        return borders.count;
    }else{
        return 0;
    }
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(pickerView == _shapePicker){
        return  [shapes objectAtIndex:row];
    }else if(pickerView == _fillColorPicker){
        return [colors objectAtIndex:row];
    }else if(pickerView == _borderStylePicker){
        return [borders objectAtIndex:row];
    }else{
        return nil;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // This method is triggered whenever the user makes a change to the picker selection.
    // The parameter named row and component represents what was selected.
    /*
    if(row == 0){ // Node
        associatedClass.visibleMode = 0;
    }else{ //Edge
        associatedClass.visibleMode = 1;
    }*/
}
@end
