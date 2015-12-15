//
//  Palette.m
//  DiagramEditor
//
//  Created by Diego Vaquero Melchor on 10/12/15.
//  Copyright © 2015 Diego Vaquero Melchor. All rights reserved.
//

#import "Palette.h"
#import "AppDelegate.h"
#import "PaletteItem.h"

#define xmargin 20


@implementation Palette

@synthesize paletteItems,name;


-(void)preparePalette{
    self.contentSize = CGSizeMake(0, self.bounds.size.height);
    
    dele = [UIApplication sharedApplication].delegate;
    
    if(paletteItems == nil)
        paletteItems = [[NSMutableArray alloc] init];
    
    for(int i = 0; i< paletteItems.count; i++){
        PaletteItem * temp = [paletteItems objectAtIndex:i];
        
        //Remove all gesture recognizers
        for (UIGestureRecognizer *recognizer in temp.gestureRecognizers) {
            [temp removeGestureRecognizer:recognizer];
        }
        
        float a = 10;
        
        CGFloat x  = i* self.contentSize.height + xmargin;
        
        CGRect insideRect = CGRectMake(x, a, self.contentSize.height -2*a, self.contentSize.height -2*a);
        
        
        temp.frame = insideRect;
        
        CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
        CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
        CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
        UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
        temp.backgroundColor =color;
        
        //temp.backgroundColor = [UIColor clearColor];
        
        [self addSubview:temp];
        self.contentSize = CGSizeMake(self.contentSize.width + temp.frame.size.width + xmargin, self.contentSize.height);
    }
    self.contentSize = CGSizeMake(self.contentSize.width + xmargin, self.contentSize.height);

}


@end
