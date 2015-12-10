//
//  ConnectionDetailsViewController.h
//  DiagramEditor
//
//  Created by Diego Vaquero Melchor on 9/12/15.
//  Copyright © 2015 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Connection.h"
@class AppDelegate;

@interface ConnectionDetailsViewController : UIViewController<UITextFieldDelegate>{
    

    __weak IBOutlet UITextField *nameTextField;
    AppDelegate * dele;
}


@property Connection * conn;
@end
