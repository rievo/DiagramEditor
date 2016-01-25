//
//  ClassAttribute.m
//  DiagramEditor
//
//  Created by Diego on 22/1/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "ClassAttribute.h"

@implementation ClassAttribute


@synthesize name, type, max, min, defaultValue;


- (instancetype)init
{
    self = [super init];
    if (self) {
        self = [self initWithName:@""
                   andType:@""
                 andMaxVal:[NSNumber numberWithInt:-1]
                 andMinVal:[NSNumber numberWithInt:-1]
           andDefaultValue:nil];
    }
    return self;
}


- (instancetype)initWithName: (NSString *)n
                     andType: (NSString *)t
                   andMaxVal: (NSNumber *)ma
                   andMinVal: (NSNumber *)mi
             andDefaultValue: (NSString *)dv
{
    self = [super init];
    if (self) {
        name = n;
        type = t;
        max = ma;
        min = mi;
        defaultValue = dv;
    }
    return self;
}


@end
