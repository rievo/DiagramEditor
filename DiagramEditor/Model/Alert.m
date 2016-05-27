//
//  Alert.m
//  DiagramEditor
//
//  Created by Diego on 17/5/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "Alert.h"

@implementation Alert

@synthesize attach, text, who, date, aCId, associatedComponent, identifier;

- (void)encodeWithCoder:(NSCoder *)coder {
    
    [coder encodeObject:self.attach  forKey:@"attach"];
    [coder encodeObject:self.text  forKey:@"text"];
    [coder encodeObject:self.who  forKey:@"who"];
    [coder encodeObject:self.date  forKey:@"date"];
    [coder encodeObject:self.associatedComponent forKey:@"associatedComponent"];
    [coder encodeInt:self.identifier forKey:@"identifier"];
}


- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.attach = [coder decodeObjectForKey:@"attach"];
        self.text = [coder decodeObjectForKey:@"text"];
        self.who = [coder decodeObjectForKey:@"who"];
        self.date = [coder decodeObjectForKey:@"date"];
        self.associatedComponent = [coder decodeObjectForKey:@"associatedComponent"];
        self.identifier = [coder decodeIntForKey:@"identifier"];
    }
    return self;
}
@end
