//
//  NodeVisualInfoTableViewCell.h
//  DiagramEditor
//
//  Created by Diego on 8/9/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Component.h"
#import "Connection.h"



@interface NodeVisualInfoTableViewCell : UITableViewCell<UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>{
    NSMutableArray * colors;
    NSMutableArray * shapes;
    NSMutableArray * borders;
    
    IBOutlet UIButton *photoButton;
    
    BOOL showingPhotoButton;
    
    id delegate;
}

@property (weak, nonatomic) IBOutlet UIPickerView *shapePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *fillColorPicker;
@property (weak, nonatomic) IBOutlet UITextField *widthTextField;
@property (weak, nonatomic) IBOutlet UITextField *HeightTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *borderStylePicker;
@property (strong, nonatomic) IBOutlet UIPickerView *borderColorPicker;
@property (strong, nonatomic) IBOutlet UIButton *photoButton;

@property id delegate;

@property Component * associatedComponent;
- (IBAction)addPhoto:(id)sender;

-(void)prepareComponent;
@end

@protocol NodeVisualInfoDelegate <NSObject>

-(void)didTouchImageButton: (NodeVisualInfoTableViewCell *) cell;

@end
