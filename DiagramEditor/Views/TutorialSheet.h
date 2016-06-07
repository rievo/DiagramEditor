//
//  TutorialSheet.h
//  DiagramEditor
//
//  Created by Diego on 2/6/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AppDelegate;

@interface TutorialSheet : UIView{
    AppDelegate * dele;
}

@property (weak, nonatomic) IBOutlet UITextView *textView;


-(void)prepare;
@end
