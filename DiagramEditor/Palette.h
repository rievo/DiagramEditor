//
//  Palette.h
//  DiagramEditor
//
//  Created by Diego Vaquero Melchor on 10/12/15.
//  Copyright © 2015 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AppDelegate;
@interface Palette : UIScrollView{
    AppDelegate * dele;
    
}


-(void)preparePalette;
-(void)resetPalette;


@property NSMutableArray * paletteItems;
@property NSString * name;
@end
