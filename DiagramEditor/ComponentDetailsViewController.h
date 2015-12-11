//
//  ComponentDetailsViewController.h
//  DiagramEditor
//
//  Created by Diego Vaquero Melchor on 9/12/15.
//  Copyright © 2015 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Component;
@class AppDelegate;
@interface ComponentDetailsViewController : UIViewController<UITextFieldDelegate>{
    
    __weak IBOutlet Component *previewComponent;
    __weak IBOutlet UITextField *nameTextField;
    __weak IBOutlet UILabel *typeLabel;
    
    AppDelegate * dele;
}



@property Component * comp;
@end
