//
//  EdgeVisualInfoTableViewCell.m
//  DiagramEditor
//
//  Created by Diego on 9/9/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "EdgeVisualInfoTableViewCell.h"

@implementation EdgeVisualInfoTableViewCell


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    colors = [[NSMutableArray alloc] init];
    styles = [[NSMutableArray alloc] init];
    sourceDecorators = [[NSMutableArray alloc] init];
    targetDecorators = [[NSMutableArray alloc] init];
    
    [_strokeColorPicker setDataSource:self];
    [_strokeColorPicker setDelegate:self];
    
    [_sourceDecoratorPicker setDataSource:self];
    [_sourceDecoratorPicker setDelegate:self];
    
    [_targetDecoratorPicker setDataSource:self];
    [_targetDecoratorPicker setDelegate:self];
    
    [_lineStylePicker setDataSource:self];
    [_lineStylePicker setDelegate:self];
    
    [self fillColors];
    [self fillDecorators];
    [self fillStyles];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)prepareConnection{
    _conn = [[Connection alloc] init];
    
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
    if(pickerView == _lineStylePicker){
        return  styles.count;
    }else if(pickerView == _strokeColorPicker){
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
    if(pickerView == _lineStylePicker){
        return  [styles objectAtIndex:row];
    }else if(pickerView == _strokeColorPicker){
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
    
}

@end
