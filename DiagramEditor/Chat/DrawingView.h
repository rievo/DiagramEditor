//
//  DrawingView.h
//  DiagramEditor
//
//  Created by Diego on 25/5/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"


@class EditorViewController;

@interface DrawingView : UIView{
     UIBezierPath *path;
    AppDelegate * dele;
    UIView * canvas;
    id delegate;
}


@property EditorViewController * owner;


@property id delegate;
- (IBAction)cancelDrawing:(id)sender;
- (IBAction)saveDrawing:(id)sender;

-(void)prepare;
@end


@protocol DrawingViewDelegate <NSObject>

-(void)drawingViewDidCancel;
-(void)drawingViewDidCloseWithPath: (UIBezierPath *)path;

@end