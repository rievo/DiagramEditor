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


@synthesize name, source, target, touchRect, arrowPath,controlPoint;
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
        name = @" -";
        controlPoint = CGPointMake(0, 0);
    }
    return self;
}



@end
