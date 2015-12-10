//
//  PaletteItem.m
//  DiagramEditor
//
//  Created by Diego Vaquero Melchor on 10/12/15.
//  Copyright © 2015 Diego Vaquero Melchor. All rights reserved.
//

#import "PaletteItem.h"

#define kEllipse @"graphicR:Ellipse"
#define kEdge @"graphicR:Edge"

@implementation PaletteItem


@synthesize type, dialog, width, height, shapeType;



- (void)drawRect:(CGRect)rect {
    
    float lw = 4.0;
    CGRect fixed = CGRectMake(2*lw, 2*lw , rect.size.width - 4*lw , rect.size.height - 4*lw);
    
    if([shapeType isEqualToString:kEllipse]){
        
        UIBezierPath * path = [UIBezierPath bezierPathWithOvalInRect:fixed];
        [[UIColor blackColor] setStroke];
        [[UIColor whiteColor] setFill];
        [path setLineWidth:lw];
        
        
        [path fill];
        [path stroke];
        
    }else if([type isEqualToString:kEdge]){

        UIBezierPath * path = [[UIBezierPath alloc]init];
        [[UIColor blackColor]setStroke];
        [path setLineWidth:lw];
        [path moveToPoint:CGPointMake(2*lw, rect.size.height /2)];
        [path addLineToPoint:CGPointMake(rect.size.width - 2* lw, rect.size.height /2)];
        
        [path stroke];
    }else{
        
    }
}


#pragma mark NSCopying
/*
-(id)copyWithZone:(NSZone *)zone{
    PaletteItem * copy = [[PaletteItem allocWithZone:zone] init];
    copy set
}*/


@end
