//
//  Connection.m
//  DiagramEditor
//
//  Created by Diego Vaquero Melchor on 9/12/15.
//  Copyright © 2015 Diego Vaquero Melchor. All rights reserved.
//

#import "Connection.h"
#import "Component.h"

@implementation Connection


@synthesize  source, target, arrowPath,controlPoint, className, attributes, sourceDecorator, targetDecorator;
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init
{
    self = [super init];
    if (self) {
        source = nil;
        target = nil;
        arrowPath = nil;
        //name = @"";
        controlPoint = CGPointMake(0, 0);
        className = @"";
        attributes = [[NSMutableArray alloc] init];
        sourceDecorator = @"noDecoration";
        targetDecorator = @"noDecoration";
    }
    return self;
}




@end
