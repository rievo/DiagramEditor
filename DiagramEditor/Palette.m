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
#define distanceToBorder 10
#define separationBetweenElements 20


@implementation Palette

@synthesize paletteItems,name;


-(void)preparePalette{
    
     dele = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSLog(@"Contentsizebefore = (%f,%f)", self.contentSize.width, self.contentSize.height);
    
    //self.delegate = self;
    
    self.contentSize = CGSizeMake(0, self.frame.size.width);
    NSLog(@"Contentsizeafter = (%f,%f)", self.contentSize.width, self.contentSize.height);
   
    NSLog(@"\n");
    //self.backgroundColor = dele.blue0;
    
    if(paletteItems == nil)
        paletteItems = [[NSMutableArray alloc] init];
    
    for(int i = 0; i< paletteItems.count; i++){
        PaletteItem * temp = [paletteItems objectAtIndex:i];
        
        //Remove all gesture recognizers
        for (UIGestureRecognizer *recognizer in temp.gestureRecognizers) {
            [temp removeGestureRecognizer:recognizer];
        }
        
        float a = distanceToBorder;
        
        CGFloat x  = i* self.frame.size.height + xmargin;
        x = x + i* separationBetweenElements;
        
        CGRect insideRect = CGRectMake(x, a, self.frame.size.height -2*a, self.frame.size.height -2*a);
        
        
        temp.frame = insideRect;
        

        temp.backgroundColor = [UIColor clearColor];
        

        [self addSubview:temp];
        self.contentSize = CGSizeMake(self.contentSize.width + temp.frame.size.width + xmargin + separationBetweenElements,
                                      self.frame.size.height);
        
        
    }
    self.contentSize = CGSizeMake(self.contentSize.width + xmargin, self.frame.size.height);
    
    self.delegate = self;

}


-(void)resetPalette{
    PaletteItem * pi = nil;
    for(int i = 0; i< paletteItems.count; i++){
        pi = [paletteItems objectAtIndex:i];
        [pi removeFromSuperview];
    }
    paletteItems = [[NSMutableArray alloc] init];
}
@end
