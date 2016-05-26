//
//  YesOrNoView.h
//  DiagramEditor
//
//  Created by Diego on 26/5/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawnAlert.h"

@interface YesOrNoView : UIView{
    id delegate;
}

@property id delegate;
@property DrawnAlert * al;


@end


@protocol YesOrNoDelegate <NSObject>

-(void)confirmDeleteDrawnAlert: (DrawnAlert *)alert;

@end


