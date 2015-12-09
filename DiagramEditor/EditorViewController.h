//
//  EditorViewController.h
//  DiagramEditor
//
//  Created by Diego Vaquero Melchor on 9/12/15.
//  Copyright © 2015 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Component.h"
#import "AppDelegate.h"
#import "Canvas.h"

@interface EditorViewController : UIViewController{
    AppDelegate * dele;
}

@property (weak, nonatomic) IBOutlet Canvas *canvas;

- (IBAction)addElement:(id)sender;

@end
