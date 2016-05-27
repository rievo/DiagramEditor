//
//  DrawnAlert.m
//  DiagramEditor
//
//  Created by Diego on 25/5/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "DrawnAlert.h"

@implementation DrawnAlert

@synthesize who, date, path, color, identifier;

- (void)encodeWithCoder:(NSCoder *)coder {

    [coder encodeObject:self.who  forKey:@"who"];
    [coder encodeObject:self.date  forKey:@"date"];
    [coder encodeObject:self.path forKey:@"path"];
    [coder encodeObject:self.color forKey:@"color"];
    [coder encodeInt:self.identifier forKey:@"identifier"];
}


- (id)initWithCoder:(NSCoder *)coder {

    self = [super init];
    if (self) {
        
        self.who = [coder decodeObjectForKey:@"who"];
        self.date = [coder decodeObjectForKey:@"date"];
        self.path = [coder decodeObjectForKey:@"path"];
        self.color = [coder decodeObjectForKey:@"color"];
        self.identifier = [coder decodeIntForKey:@"identifier"];
    }
    return self;
}


@end
