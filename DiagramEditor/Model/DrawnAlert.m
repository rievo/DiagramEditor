//
//  DrawnAlert.m
//  DiagramEditor
//
//  Created by Diego on 25/5/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "DrawnAlert.h"

@implementation DrawnAlert

@synthesize who, date, path;

- (void)encodeWithCoder:(NSCoder *)coder {

    [coder encodeObject:self.who  forKey:@"who"];
    [coder encodeObject:self.date  forKey:@"date"];
    [coder encodeObject:self.path forKey:@"path"];
    
}


- (id)initWithCoder:(NSCoder *)coder {

    self = [super init];
    if (self) {
        
        self.who = [coder decodeObjectForKey:@"who"];
        self.date = [coder decodeObjectForKey:@"date"];
        self.path = [coder decodeObjectForKey:@"path"];
    }
    return self;
}


@end
