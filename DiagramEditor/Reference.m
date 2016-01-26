//
//  Reference.m
//  DiagramEditor
//
//  Created by Diego on 26/1/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "Reference.h"

@implementation Reference

@synthesize name, containment, target, opposite, max, min;

- (instancetype)initWithName: (NSString *)n
                     andContainment: (BOOL)c
                   andTarget: (NSString *)t
                 andOpposite: (NSString *)o
                   andMaxVal: (NSNumber *)ma
                   andMinVal: (NSNumber *)mi
{
    self = [super init];
    if (self) {
        name = n;
        max = ma;
        min = mi;
        target = t;
        opposite = o;
        containment = c;
    }
    return self;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        self = [self initWithName:@""
                   andContainment:NO
                        andTarget:nil
                      andOpposite:nil
                        andMaxVal:[NSNumber numberWithInt:0]
                        andMinVal:[NSNumber numberWithInt:0]];
    }
    return self;
}



@end
