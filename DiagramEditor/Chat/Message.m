//
//  Message.m
//  DiagramEditor
//
//  Created by Diego on 11/5/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "Message.h"

@implementation Message

@synthesize content, who, date;


#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:content forKey:@"content"];
    [coder encodeObject:who forKey:@"who"];
    [coder encodeObject:date forKey:@"date"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.content = [coder decodeObjectForKey:@"content"];
        self.who = [coder decodeObjectForKey:@"who"];
        self.date = [coder decodeObjectForKey:@"date"];
    }
    return self;
}



@end
