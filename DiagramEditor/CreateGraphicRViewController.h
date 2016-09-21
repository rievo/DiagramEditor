//
//  CreateGraphicRViewController.h
//  DiagramEditor
//
//  Created by Diego on 12/9/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JsonClass.h"
#import "EcoreFile.h"

@interface CreateGraphicRViewController : UIViewController<UIAlertViewDelegate>{
    NSString * text;
    __weak IBOutlet UITextView *textview;
    UIAlertView * goodAlert;
    UIAlertView * badAlert;
    __weak IBOutlet UITextField *nameTextField;
    __weak IBOutlet UIButton *createButton;
    
    NSString * extension;
}



@property NSMutableArray * nodes;
@property NSMutableArray * edges;

@property NSMutableArray * visibles;
@property NSMutableArray * hidden;

@property JsonClass * root;

@property NSMutableArray * classes;

@property EcoreFile * selectedJson;

- (IBAction)updateName:(id)sender;
@end
