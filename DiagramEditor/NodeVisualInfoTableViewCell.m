//
//  NodeVisualInfoTableViewCell.m
//  DiagramEditor
//
//  Created by Diego on 8/9/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "NodeVisualInfoTableViewCell.h"

@implementation NodeVisualInfoTableViewCell

@synthesize associatedComponent;

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
    
    //associatedComponent = (Component *)associatedComponent;
    
    [self prepareComponent];
}

-(void)prepareComponent{
    
    
    
    
    associatedComponent.type = @"graphicR:Node";
    
    NSInteger index = [_shapePicker selectedRowInComponent:0];
    associatedComponent.shapeType = [shapes objectAtIndex:index];
    
    index = [_fillColorPicker selectedRowInComponent:0];
    associatedComponent.colorString = [colors objectAtIndex:index];
    
    associatedComponent.borderColorString = @"black";
    
    index = [_borderStylePicker selectedRowInComponent:0];
    associatedComponent.borderStyleString = [borders objectAtIndex:index];
    
    index = [_shapePicker selectedRowInComponent:0];
    associatedComponent.shapeType = [shapes objectAtIndex:index];

    
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
              @"white",
              @"black",
              @"orange",
              @"blue",
              @"chocolate",
              @"gray",
              @"green",
              @"purple",
              @"red",
              @"yellow",
              @"light_blue",
              @"light_chocolate",
              @"light_gray",
              @"light_green",
              @"light_orange",
              @"light_purple",
              @"light_red",
              @"light_yellow",
              @"dark_blue",
              @"dark_chocolate",
              @"dark_gray",
              @"dark_orange",
              @"dark_purple",
              @"dark_red",
              @"dark_yellow",
              @"dark_green",nil];
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
    
    if(pickerView == _shapePicker){
        associatedComponent.shapeType = [shapes objectAtIndex:row];
    }else if(pickerView == _fillColorPicker){
        associatedComponent.colorString = [colors objectAtIndex:row];
    }else if(pickerView == _borderStylePicker){
        associatedComponent.borderStyleString = [borders objectAtIndex:row];
    }

}
@end
