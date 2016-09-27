//
//  ReferenciVisualInfoTableViewCell.m
//  DiagramEditor
//
//  Created by Diego on 8/9/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "ReferenciVisualInfoTableViewCell.h"

@implementation ReferenciVisualInfoTableViewCell

@synthesize ref;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    

}

-(void)prepare{
    colors = [[NSMutableArray alloc] init];
    styles = [[NSMutableArray alloc] init];
    sourceDecorators = [[NSMutableArray alloc] init];
    targetDecorators = [[NSMutableArray alloc] init];
    
    [_colorPicker setDataSource:self];
    [_colorPicker setDelegate:self];
    
    [_sourceDecoratorPicker setDataSource:self];
    [_sourceDecoratorPicker setDelegate:self];
    
    [_targetDecoratorPicker setDataSource:self];
    [_targetDecoratorPicker setDelegate:self];
    
    [_stylePicker setDataSource:self];
    [_stylePicker setDelegate:self];
    
    [self fillColors];
    [self fillDecorators];
    [self fillStyles];
    
    NSInteger index = [_colorPicker selectedRowInComponent:0];
    ref.color = [colors objectAtIndex:index];
    
    index = [_stylePicker selectedRowInComponent:0];
    ref.style = [styles objectAtIndex:index];
    
    index = [_sourceDecoratorPicker selectedRowInComponent:0];
    ref.sourceDecorator = [sourceDecorators objectAtIndex:index];
    
    index = [_targetDecoratorPicker selectedRowInComponent:0];
    ref.targetDecorator = [targetDecorators objectAtIndex:index];
}


-(void)fillDecorators{
    [sourceDecorators addObject:@"noDecoration"];
    [sourceDecorators addObject:@"inputArrow"];
    [sourceDecorators addObject:@"diamond"];
    [sourceDecorators addObject:@"fillDiamond"];
    [sourceDecorators addObject:@"inputClosedArrow"];
    [sourceDecorators addObject:@"inputFillClosedArrow"];
    [sourceDecorators addObject:@"outputArrow"];
    [sourceDecorators addObject:@"outputClosedArrow"];
    [sourceDecorators addObject:@"outputFillClosedArrow"];
    
    [targetDecorators addObject:@"noDecoration"];
    [targetDecorators addObject:@"inputArrow"];
    [targetDecorators addObject:@"diamond"];
    [targetDecorators addObject:@"fillDiamond"];
    [targetDecorators addObject:@"inputClosedArrow"];
    [targetDecorators addObject:@"inputFillClosedArrow"];
    [targetDecorators addObject:@"outputArrow"];
    [targetDecorators addObject:@"outputClosedArrow"];
    [targetDecorators addObject:@"outputFillClosedArrow"];
}

-(void)fillStyles{
    
    [styles addObject:@"solid"];
    [styles addObject:@"dash"];
    [styles addObject:@"dot"];
    [styles addObject:@"dash_dot"];
}

-(void)fillColors{
    colors = [[NSMutableArray alloc] initWithObjects:
              @"orange",
              @"black",
              @"white",
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
    if(pickerView == _stylePicker){
        return  styles.count;
    }else if(pickerView == _colorPicker){
        return colors.count;
    }else if(pickerView == _sourceDecoratorPicker){
        return sourceDecorators.count;
    }else if(pickerView == _targetDecoratorPicker){
        return targetDecorators.count;
    }else{
        return 0;
    }
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(pickerView == _stylePicker){
        return  [styles objectAtIndex:row];
    }else if(pickerView == _colorPicker){
        return [colors objectAtIndex:row];
    }else if(pickerView == _sourceDecoratorPicker){
        return [sourceDecorators objectAtIndex:row];
    }else if(pickerView == _targetDecoratorPicker){
        return [targetDecorators objectAtIndex:row];
    }else{
        return nil;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if(pickerView == _stylePicker){
        ref.style = [styles objectAtIndex:row];
    }else if(pickerView == _colorPicker){
        ref.color = [colors objectAtIndex:row];
    }else if(pickerView == _sourceDecoratorPicker){
        ref.sourceDecorator = [sourceDecorators objectAtIndex:row];
    }else if(pickerView == _targetDecoratorPicker){
        ref.targetDecorator = [targetDecorators objectAtIndex:row];
    }
}

@end
