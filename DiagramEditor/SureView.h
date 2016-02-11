//
//  SureView.h
//  DiagramEditor
//
//  Created by Diego on 26/1/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SureViewDelegate
-(void)closeSureViewWithResult: (BOOL)res;
@end


@interface SureView : UIView<UIGestureRecognizerDelegate>{
    id delegate;
    
    
}



@property (weak, nonatomic) IBOutlet UIView *background;

@property (nonatomic, retain) id delegate;

- (IBAction)sayNo:(UIButton *)sender;
- (IBAction)sayYes:(id)sender;


@end
