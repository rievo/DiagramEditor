//
//  ClassAttribute.m
//  DiagramEditor
//
//  Created by Diego on 22/1/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "ClassAttribute.h"

@implementation ClassAttribute


@synthesize name, type, max, min, defaultValue, currentValue, isLabel;


- (instancetype)init
{
    self = [super init];
    if (self) {
        self = [self initWithName:@""
                   andType:@""
                 andMaxVal:[NSNumber numberWithInt:-1]
                 andMinVal:[NSNumber numberWithInt:-1]
           andDefaultValue:@""];
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
        isLabel = false;
    }
    return self;
}


#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.type forKey:@"type"];
    [coder encodeObject:self.min forKey:@"min"];
    [coder encodeObject:self.max forKey:@"max"];
    [coder encodeObject:self.defaultValue forKey:@"defaultvalue"];
    [coder encodeObject:self.currentValue forKey:@"currentvalue"];
    [coder encodeBool:self.isLabel forKey:@"isLabel"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {

        self.name = [coder decodeObjectForKey:@"name"];
        self.type = [coder decodeObjectForKey:@"type"];
        self.min = [coder decodeObjectForKey:@"min"];
        self.max = [coder decodeObjectForKey:@"max"];
        self.defaultValue = [coder decodeObjectForKey:@"defaultvalue"];
        self.currentValue = [coder decodeObjectForKey:@"currentvalue"];
        self.isLabel = [coder decodeBoolForKey:@"isLabel"];
    }
    return self;
}



@end
