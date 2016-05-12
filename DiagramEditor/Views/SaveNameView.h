//
//  SaveNameView.h
//  DiagramEditor
//
//  Created by Diego on 25/1/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SaveNameDelegate
-(void)saveName: (NSString *)name;
    -(void)cancelSaving;
@end

@interface SaveNameView : UIView<UIGestureRecognizerDelegate>{
    id delegate;
    __weak IBOutlet UIView *background;
}

@property (nonatomic, retain) id delegate;
@property (weak, nonatomic) IBOutlet UITextField *textField;

- (IBAction)confirmSaving:(id)sender;
- (IBAction)cancelSaving:(id)sender;
@end
