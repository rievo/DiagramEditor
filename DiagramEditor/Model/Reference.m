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


#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.target forKey:@"target"];
    [coder encodeObject:self.min forKey:@"min"];
    [coder encodeObject:self.max forKey:@"max"];
    [coder encodeObject:self.opposite forKey:@"opposite"];
    [coder encodeBool:self.containment forKey:@"containment"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        
        self.name = [coder decodeObjectForKey:@"name"];
        self.target = [coder decodeObjectForKey:@"target"];
        self.min = [coder decodeObjectForKey:@"min"];
        self.max = [coder decodeObjectForKey:@"max"];
        self.opposite = [coder decodeObjectForKey:@"opposite"];
        self.containment = [coder decodeBoolForKey:@"containment"];
    }
    return self;
}



@end
