//
//  ConfigureDiagramViewController.h
//  DiagramEditor
//
//  Created by Diego Vaquero Melchor on 9/12/15.
//  Copyright © 2015 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AppDelegate;


@interface ConfigureDiagramViewController : UIViewController<UIScrollViewDelegate, UIGestureRecognizerDelegate>{
    NSDictionary * configuration;
    AppDelegate * dele;
    __weak IBOutlet UIScrollView *scrollView;
    __weak IBOutlet UIView *infoView;
    __weak IBOutlet UILabel *infoLabel;
    
    CGRect initialInfoPosition;
}

@end
