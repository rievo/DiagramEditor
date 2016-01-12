//
//  PaletteItemCreatorViewController.h
//  DiagramEditor
//
//  Created by Diego Vaquero Melchor on 12/1/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PItemEditor.h"
@class AppDelegate;

@interface PaletteItemCreatorViewController : UIViewController{
    
    __weak IBOutlet PItemEditor *canvas;
    AppDelegate * dele;
}

- (IBAction)closePItemCreator:(id)sender;


@end
