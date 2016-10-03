//
//  NodeVisualInfoTableViewCell.m
//  DiagramEditor
//
//  Created by Diego on 8/9/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "NodeVisualInfoTableViewCell.h"
#import "ColorPalette.h"

@implementation NodeVisualInfoTableViewCell

@synthesize associatedComponent, delegate, photoButton;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self hideImageButtonAnimated:NO];
    showingPhotoButton = NO;
    
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
    
    [_borderColorPicker setDelegate:self];
    [_borderColorPicker setDataSource:self];
    
    _HeightTextField.delegate = self;
    _widthTextField.delegate = self;
    
    //associatedComponent = (Component *)associatedComponent;
    
    [self prepareComponent];
}

-(void)showImageButton{
    [photoButton setAlpha:0];
    [photoButton setHidden:NO];
    /*
    [UIView animateWithDuration:0.3
                          delay:0.0
         usingSpringWithDamping:10
          initialSpringVelocity:0
                        options:0
                     animations:^{
                         [photoButton setAlpha:1.0];
                     }
                     completion:^(BOOL finished){
                         
                         [photoButton setEnabled:YES];
                         showingPhotoButton = YES;
                     }];*/
    [UIView beginAnimations:@"showImageButtom" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(showButtonAnimationFinished)];
    [photoButton setAlpha:1.0];
    [UIView commitAnimations];
}


-(void)textFieldDidEndEditing:(UITextField *)textField{
    if(textField.text.length == 0){
        if(textField == _widthTextField){
            _widthTextField.text = @"6";
            associatedComponent.width = [textField.text floatValue];
        }else if(textField == _HeightTextField){
            _HeightTextField.text = @"6";
            associatedComponent.height = [textField.text floatValue];
        }
    }else{
        if(textField == _widthTextField){
            associatedComponent.width = [textField.text floatValue];
        }else if(textField == _HeightTextField){
            associatedComponent.height = [textField.text floatValue];
        }
    }
    
}


-(void)showButtonAnimationFinished{
    [photoButton setEnabled:YES];
    showingPhotoButton = YES;
}

-(void)hideImageButtonAnimated:(BOOL)animated{
    
    if(animated == YES){
        [photoButton setEnabled:NO];
        
        [UIView animateWithDuration:0.5
                              delay:0
             usingSpringWithDamping:10
              initialSpringVelocity:0
                            options:0
                         animations:^{
                             [photoButton setAlpha:0];
                         }
                         completion:^(BOOL finished){
                             [photoButton setHidden:YES];
                         }];
    }else{
        [photoButton setHidden:YES];
        [photoButton setEnabled:NO];
    }
    
    showingPhotoButton = NO;
}

- (IBAction)addPhoto:(id)sender {
    /*UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Alert title"
                                                                             message:@"Alert message"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    */
    
    [delegate didTouchImageButton:self];
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
    
    index = [_borderColorPicker selectedRowInComponent:0];
    associatedComponent.borderColorString = [shapes objectAtIndex:index];
    
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
    [shapes addObject:@"Image"];
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
    }else if(pickerView == _borderColorPicker){
        return colors.count;
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
    }else if(pickerView == _borderColorPicker){
        return [colors objectAtIndex:row];
    }else{
        return nil;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    if(pickerView == _shapePicker){
        NSString * selected = [shapes objectAtIndex:row];
        
        if([selected isEqualToString:@"Image"]){
            [self showImageButton];
        }else{
            associatedComponent.shapeType = [shapes objectAtIndex:row];
            
            //Hide photo button
            if(showingPhotoButton == YES){
                [self hideImageButtonAnimated:YES];
            }
        }
    }else if(pickerView == _fillColorPicker){
        associatedComponent.colorString = [colors objectAtIndex:row];
    }else if(pickerView == _borderStylePicker){
        associatedComponent.borderStyleString = [borders objectAtIndex:row];
    }else if(pickerView == _borderColorPicker){
        associatedComponent.borderColorString = [colors objectAtIndex:row];
    }
    
}

-(UIView *)pickerView:(UIPickerView *)pickerView
           viewForRow:(NSInteger)row
         forComponent:(NSInteger)component
          reusingView:(UIView *)view{
    UIView * v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pickerView.frame.size.width, pickerView.frame.size.height -5)];

    
    if(pickerView == _fillColorPicker){
        NSString * colorName = [colors objectAtIndex:row];
        float margin = 5;
        UIView * colorView = [[UIView alloc] initWithFrame:CGRectMake(margin,
                                                                     margin,
                                                                     v.frame.size.width - 2*margin,
                                                                     v.frame.size.height - 2*margin)];
        UIColor * color = [ColorPalette colorForString:colorName];
        [colorView setBackgroundColor:color];
        
        
        UILabel * label = [[UILabel alloc] initWithFrame:v.frame];
        
        UIColor * textColor = nil;
        
        if([colorName isEqualToString:@"black"]){
            textColor = [UIColor whiteColor];
        }else{
            textColor = [UIColor blackColor];
        }
        
        label.text = [colors objectAtIndex:row];
        label.textColor = textColor;
        [label setTextAlignment:NSTextAlignmentCenter];
        label.adjustsFontSizeToFitWidth = YES;
        label.minimumScaleFactor = 0.5;
        
        
        [v addSubview: colorView];
        [v addSubview:label];
        
    }else if(pickerView == _borderStylePicker){

        UILabel * label = [[UILabel alloc] initWithFrame:v.frame];
        label.text = [borders objectAtIndex:row];
        [label setTextAlignment:NSTextAlignmentCenter];
        label.adjustsFontSizeToFitWidth = YES;
        label.minimumScaleFactor = 0.5;
        [v addSubview:label];
    
    }else if(pickerView == _shapePicker){
        UILabel * label = [[UILabel alloc] initWithFrame:v.frame];
        label.text = [shapes objectAtIndex:row];
        [label setTextAlignment:NSTextAlignmentCenter];
        label.adjustsFontSizeToFitWidth = YES;
        label.minimumScaleFactor = 0.5;
        [v addSubview:label];
    }else if(pickerView == _borderColorPicker) {
        NSString * colorName = [colors objectAtIndex:row];
        float margin = 5;
        UIView * colorView = [[UIView alloc] initWithFrame:CGRectMake(margin,
                                                                      margin,
                                                                      v.frame.size.width - 2*margin,
                                                                      v.frame.size.height - 2*margin)];
        UIColor * color = [ColorPalette colorForString:colorName];
        [colorView setBackgroundColor:color];
        
        
        UILabel * label = [[UILabel alloc] initWithFrame:v.frame];
        
        UIColor * textColor = nil;
        
        if([colorName isEqualToString:@"black"]){
            textColor = [UIColor whiteColor];
        }else{
            textColor = [UIColor blackColor];
        }
        
        label.text = [colors objectAtIndex:row];
        label.textColor = textColor;
        [label setTextAlignment:NSTextAlignmentCenter];
        label.adjustsFontSizeToFitWidth = YES;
        label.minimumScaleFactor = 0.5;
        
        
        [v addSubview: colorView];
        [v addSubview:label];
    }
    return  v;
}
@end
