//
//  YesOrNoView.m
//  DiagramEditor
//
//  Created by Diego on 26/5/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "YesOrNoView.h"

@implementation YesOrNoView

@synthesize al, delegate;

-(void)awakeFromNib{
    [super awakeFromNib];
    UITapGestureRecognizer * gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:gr];
}

-(void)handleTap:(UITapGestureRecognizer*)recog{
    [self removeFromSuperview];
    [delegate confirmDeleteDrawnAlert:al];
}


@end
